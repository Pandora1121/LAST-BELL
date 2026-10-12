extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var manager = load("res://scripts/autoload/save_manager.gd").new()
	root.add_child(manager)
	var original_sensitivity: float = manager.mouse_sensitivity
	var original_volume: float = manager.master_volume_db
	var original_fullscreen: bool = manager.fullscreen
	manager.mouse_sensitivity = 0.0027
	manager.master_volume_db = -9.0
	manager.fullscreen = true
	manager.save_settings()
	manager.mouse_sensitivity = 0.001
	manager.master_volume_db = -20.0
	manager.fullscreen = false
	manager.load_settings()
	assert(is_equal_approx(manager.mouse_sensitivity, 0.0027), "Mouse sensitivity must persist")
	assert(is_equal_approx(manager.master_volume_db, -9.0), "Master volume must persist")
	assert(manager.fullscreen, "Fullscreen preference must persist")
	manager.mouse_sensitivity = original_sensitivity
	manager.master_volume_db = original_volume
	manager.fullscreen = original_fullscreen
	manager.save_settings()
	print("Settings persistence test passed")
	quit(0)
