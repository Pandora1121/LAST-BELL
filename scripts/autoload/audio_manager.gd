extends Node

var ambience_player: AudioStreamPlayer
var bell_player: AudioStreamPlayer
var announcement_timer: Timer

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
