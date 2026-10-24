extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var game: Node = load("res://scenes/main/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	var player := game.get("player") as CharacterBody3D
	var camera := player.get_node("Camera3D") as Camera3D
	assert(camera.position.z > 2.0, "Player camera must sit behind the character")
	var focus_point := player.global_position + Vector3(0.0, 1.0, 0.0)
	var to_character := (focus_point - camera.global_position).normalized()
	assert((-camera.global_basis.z).dot(to_character) > 0.95, "Player camera must aim toward the character")
	var hands := player.get("hands_rig") as Node3D
	assert(hands == null or not hands.visible, "First-person hands must not float in third-person view")
	if ResourceLoader.exists("res://assets/characters/hina/model.glb"):
		var character := player.get_node_or_null("HinaCharacter") as Node3D
		assert(character != null, "The local Hina GLB must be instanced for the player")
		var meshes := character.find_children("*", "GeometryInstance3D", true, false)
		assert(not meshes.is_empty(), "The Hina character must contain visible meshes")
		for mesh_node in meshes:
			var mesh := mesh_node as GeometryInstance3D
			assert(mesh.layers == 1, "The Hina character must be visible to the player camera")
			assert(mesh.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_ON, "The visible character must cast normal shadows")
	print("Player third-person camera test passed")
	quit(0)
