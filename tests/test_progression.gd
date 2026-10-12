extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var game = load("res://scenes/main/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	var fuse = game.find_child("Fuse", true, false)
	var panel = game.find_child("ElectricalPanel", true, false)
	var locker = game.find_child("Locker14", true, false)
	var door = game.find_child("ExitDoor", true, false)
	assert(fuse != null and panel != null and locker != null and door != null, "Progression props must exist")
	locker.interact(game.player, game)
	assert(not game.has_key, "Exit key must remain unavailable before power is restored")
	fuse.interact(game.player, game)
	assert(game.has_fuse, "Fuse pickup must update inventory state")
	panel.interact(game.player, game)
	assert(game.power_restored, "Panel must accept the fuse")
	locker.interact(game.player, game)
	game._submit_locker_code("0000")
	assert(not game.has_key, "Incorrect locker code must not grant the exit key")
	game._submit_locker_code("1947")
	assert(game.has_key, "Exit key must be available after restoring power")
	door.interact(game.player, game)
	assert(game.get_tree().paused, "Unlocking the exit must reach the ending state")
	print("Progression test passed")
	quit(0)
