extends Node

const SETTINGS_PATH := "user://settings.cfg"
var mouse_sensitivity := 0.0018
var master_volume_db := 0.0
var fullscreen := false

func _ready() -> void:
	load_settings()

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return
	mouse_sensitivity = float(config.get_value("controls", "mouse_sensitivity", mouse_sensitivity))
	master_volume_db = float(config.get_value("audio", "master_volume_db", master_volume_db))
	fullscreen = bool(config.get_value("display", "fullscreen", fullscreen))
	_apply_settings()

func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("controls", "mouse_sensitivity", mouse_sensitivity)
	config.set_value("audio", "master_volume_db", master_volume_db)
	config.set_value("display", "fullscreen", fullscreen)
	config.save(SETTINGS_PATH)
	_apply_settings()

func _apply_settings() -> void:
	AudioServer.set_bus_volume_db(0, master_volume_db)
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
