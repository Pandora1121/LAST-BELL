extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var game = load("res://scenes/main/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await physics_frame
	assert(game.objective_label.text.contains("Find the fuse"), "The starting objective must be visible")
	var fuse = game.find_child("Fuse", true, false)
	var panel = game.find_child("ElectricalPanel", true, false)
	var locker = game.find_child("Locker14", true, false)
	var door = game.find_child("ExitDoor", true, false)
	assert(fuse != null and panel != null and locker != null and door != null, "Progression props must exist")
	var space: PhysicsDirectSpaceState3D = game.get_world_3d().direct_space_state
	var fuse_query := PhysicsRayQueryParameters3D.create(Vector3(0, 1.0, -13), Vector3(-8.1, 1.0, -13))
	var fuse_hit: Dictionary = space.intersect_ray(fuse_query)
	assert(fuse_hit.get("collider") == fuse, "The fuse must be reachable through the classroom doorway")
	var locker_query := PhysicsRayQueryParameters3D.create(Vector3(0, 1.2, -3), Vector3(8.8, 1.2, -3))
	var locker_hit: Dictionary = space.intersect_ray(locker_query)
	assert(locker_hit.get("collider") == locker, "The locker must be reachable through the teachers' room doorway")
	locker.interact(game.player, game)
	assert(not game.has_key, "Exit key must remain unavailable before power is restored")
	fuse.interact(game.player, game)
	assert(game.has_fuse, "Fuse pickup must update inventory state")
	assert(game.inventory_label.text.contains("Fuse"), "The HUD must show the collected fuse")
	assert(game.objective_label.text.contains("electrical panel"), "The next objective must point to the panel")
	panel.interact(game.player, game)
	assert(game.power_restored, "Panel must accept the fuse")
	assert(game.objective_label.text.contains("locker 14"), "The next objective must point to the coded locker")
	locker.interact(game.player, game)
	game._submit_locker_code("0000")
	assert(not game.has_key, "Incorrect locker code must not grant the exit key")
	game._submit_locker_code("1947")
	assert(game.has_key, "Exit key must be available after restoring power")
	assert(game.inventory_label.text.contains("Exit key"), "The HUD must show the collected key")
	assert(game.objective_label.text.contains("Unlock the exit"), "The final objective must point to the exit")
	door.interact(game.player, game)
	assert(game.get_tree().paused, "Unlocking the exit must reach the ending state")
	assert(game.game_complete and game.objective_label.text.contains("Objective complete"), "The ending must mark the objective complete")
	print("Progression test passed")
	quit(0)
