extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var game = load("res://scenes/main/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	var pause_event := InputEventAction.new()
	pause_event.action = "pause"
	pause_event.pressed = true
	game._unhandled_input(pause_event)
	assert(game.get_tree().paused and game.pause_panel.visible, "Pause input must open the pause menu")
	game._resume_game()
	assert(not game.get_tree().paused and not game.pause_panel.visible, "Resume must close pause menu")
	game.show_game_over()
	assert(game.game_over and game.get_tree().paused, "Game over must stop gameplay")
	print("Pause and recovery state test passed")
	quit(0)
