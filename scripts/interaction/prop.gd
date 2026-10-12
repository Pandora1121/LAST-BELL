extends StaticBody3D

@export var prompt := "[E] Interact"
var used := false

func interact(_player: CharacterBody3D, game: Node) -> void:
	var kind: String = str(get_meta("kind", ""))
	match kind:
		"fuse":
			if not game.has_fuse:
				game.has_fuse = true
				game.set_message("Fuse collected. Find the electrical panel.")
				queue_free()
			else:
				game.set_message("You already have the fuse.")
		"key":
			if not game.power_restored:
				game.set_message("The key is stuck in the locker. Restore power first.")
			elif not game.has_key:
				game.has_key = true
				game.set_message("Exit key collected. Return to the lobby.")
				queue_free()
		"locker":
			if not game.power_restored:
				game.set_message("Locker 14 is jammed shut. Restore power first.")
			else:
				game.request_locker_code()
		"panel":
			if not game.has_fuse:
				game.set_message("A fuse is missing. Search the classrooms.")
			else:
				game.power_restored = true
				game.set_message("Power restored. A locker clicks open down the hall.")
		"door":
			if not game.has_key:
				game.set_message("Locked. The exit key is somewhere in the school.")
			else:
				game.set_message("The final bell rings. You escape into the night.")
				game.status_label.add_theme_color_override("font_color", Color(0.8, 0.9, 0.72))
				game.get_tree().paused = true
		"note":
			game.set_message("Torn note: “Locker 14. The code is 1947. Don't answer the bell.”")
