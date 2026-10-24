extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var game = load("res://scenes/main/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await physics_frame
	var player: CharacterBody3D = game.player
	player.global_position = Vector3(3.2, 0.1, -3.0)
	player.velocity = Vector3.ZERO
	await physics_frame
	var collision: KinematicCollision3D = player.move_and_collide(Vector3(4.0, 0.0, 0.0))
	assert(collision == null, "Player capsule should pass through the first right doorway without hitting geometry")
	assert(player.global_position.x >= 7.1, "Player should reach the teachers' room side of the doorway")
	print("First right doorway collision check passed")
	quit(0)
