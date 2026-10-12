extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await process_frame
	var manager := root.get_node_or_null("AudioManager")
	assert(manager != null, "AudioManager autoload must be present")
	assert(manager.ambience_player.stream != null, "School ambience must have an audio stream")
	assert(manager.ambience_player.stream is AudioStreamWAV, "School ambience must load as a WAV stream")
	assert(manager.bell_player.stream != null, "The distant bell must have an audio stream")
	assert((manager.ambience_player.stream as AudioStreamWAV).loop_mode == AudioStreamWAV.LOOP_FORWARD, "School ambience must loop seamlessly")
	assert(AudioServer.get_bus_index("Ambience") >= 0, "Ambience bus must be configured")
	assert(AudioServer.get_bus_index("Voice") >= 0, "Voice bus must be configured")
	print("Audio setup test passed")
	manager.announcement_timer.stop()
	manager.ambience_player.stop()
	manager.bell_player.stop()
	manager.ambience_player.stream = null
	manager.bell_player.stream = null
	await create_timer(0.5).timeout
	manager.free()
	await process_frame
	quit(0)
