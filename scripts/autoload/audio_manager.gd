extends Node

var ambience_player: AudioStreamPlayer
var bell_player: AudioStreamPlayer
var announcement_timer: Timer
var sfx_streams: Dictionary = {}
var sfx_players: Array[AudioStreamPlayer] = []
var _sfx_player_cursor := 0

func _ready() -> void:
	_ensure_audio_bus("Ambience")
	_ensure_audio_bus("SFX")
	_ensure_audio_bus("Music")
	_ensure_audio_bus("Voice")
	_setup_players()
	_setup_announcement()

func _exit_tree() -> void:
	if is_instance_valid(announcement_timer):
		announcement_timer.stop()
	for player in [ambience_player, bell_player]:
		if is_instance_valid(player):
			player.stop()
			player.stream = null
	for player in sfx_players:
		if is_instance_valid(player):
			player.stop()
			player.stream = null

func _ensure_audio_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) >= 0:
		return
	var bus_index := AudioServer.get_bus_count()
	AudioServer.add_bus(bus_index)
	AudioServer.set_bus_name(bus_index, bus_name)
	AudioServer.set_bus_send(bus_index, "Master")

func _setup_players() -> void:
	ambience_player = AudioStreamPlayer.new()
	ambience_player.name = "SchoolAmbience"
	ambience_player.bus = "Ambience"
	ambience_player.volume_db = -7.0
	var ambience_stream := load("res://assets/audio/school_ambience.wav") as AudioStreamWAV
	ambience_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	ambience_stream.loop_end = ambience_stream.data.size() / 2
	ambience_player.stream = ambience_stream
	add_child(ambience_player)
	if DisplayServer.get_name() != "headless":
		ambience_player.play()
	bell_player = AudioStreamPlayer.new()
	bell_player.name = "DistantBell"
	bell_player.bus = "Voice"
	bell_player.volume_db = -6.0
	bell_player.stream = load("res://assets/audio/distant_bell.wav")
	add_child(bell_player)
	_setup_sfx_players()

func _setup_sfx_players() -> void:
	for sound_name in [&"footstep", &"pickup", &"power", &"locker", &"exit"]:
		var sound_stream := load("res://assets/audio/sfx_%s.wav" % String(sound_name)) as AudioStreamWAV
		if sound_stream != null:
			sfx_streams[sound_name] = sound_stream
	for index in range(8):
		var player := AudioStreamPlayer.new()
		player.name = "SFXPlayer%d" % index
		player.bus = "SFX"
		player.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(player)
		sfx_players.append(player)

func play_sfx(sound_name: StringName, pitch_scale := 1.0, volume_db := 0.0) -> void:
	if DisplayServer.get_name() == "headless" or not sfx_streams.has(sound_name):
		return
	for offset in range(sfx_players.size()):
		var index := (_sfx_player_cursor + offset) % sfx_players.size()
		var player := sfx_players[index]
		if not player.playing:
			player.stream = sfx_streams[sound_name]
			player.pitch_scale = clampf(pitch_scale, 0.5, 2.0)
			player.volume_db = volume_db
			player.play()
			_sfx_player_cursor = (index + 1) % sfx_players.size()
			return

func play_bell() -> void:
	if DisplayServer.get_name() == "headless" or not is_instance_valid(bell_player):
		return
	bell_player.play()

func _setup_announcement() -> void:
	announcement_timer = Timer.new()
	announcement_timer.name = "FinalBellCue"
	announcement_timer.wait_time = 72.0
	announcement_timer.one_shot = true
	announcement_timer.timeout.connect(_play_announcement)
	add_child(announcement_timer)
	announcement_timer.start()

func _play_announcement() -> void:
	bell_player.play()
	var game := get_tree().current_scene
	if is_instance_valid(game) and game.has_method("set_message"):
		game.set_message("[Distant school announcement] The final bell will ring in five minutes.")
