extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var game = load("res://scenes/main/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await process_frame
	var enemy = game.find_child("HallMonitor", true, false)
	assert(enemy != null, "Hall Monitor must exist")
	assert(enemy.navigation_agent != null, "Hall Monitor must use NavigationAgent3D")
	assert(enemy.navigation_agent.get_next_path_position() != Vector3.ZERO, "Patrol path must resolve to a point on the corridor navmesh")
	var sound_position: Vector3 = enemy.global_position + Vector3(2.0, 0.0, 0.0)
	root.get_node("NoiseManager").report_noise(sound_position, 8.0, game.player)
	assert(enemy.state == enemy.State.INVESTIGATE, "A nearby sprint noise must trigger INVESTIGATE")
	assert(enemy.last_known_position.is_equal_approx(sound_position), "The enemy must investigate the sound's last known position")
	var prior_position: Vector3 = enemy.last_known_position
	root.get_node("NoiseManager").report_noise(enemy.global_position + Vector3(40.0, 0, 0), 5.0, game.player)
	assert(enemy.last_known_position.is_equal_approx(prior_position), "Noise outside hearing range must be ignored")
	game.player.global_position = enemy.global_position + Vector3(0, 0, -4)
	enemy.look_at(game.player.global_position, Vector3.UP)
	assert(enemy._can_see_player(), "The Hall Monitor must detect a player inside its forward view")
	var occluder := StaticBody3D.new()
	occluder.position = enemy.global_position + Vector3(0, 1.0, -2)
	var occluder_shape := CollisionShape3D.new()
	var wall := BoxShape3D.new()
	wall.size = Vector3(2, 2, 0.25)
	occluder_shape.shape = wall
	occluder.add_child(occluder_shape)
	game.add_child(occluder)
	assert(not enemy._can_see_player(), "A solid wall must block visual detection")
	print("Enemy perception and navigation test passed")
	quit(0)
