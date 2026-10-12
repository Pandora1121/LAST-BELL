extends Node3D

const PlayerController = preload("res://scripts/player/player_controller.gd")
const SchoolBuilder = preload("res://scripts/levels/school_builder.gd")
const HallMonitor = preload("res://scripts/enemy/hall_monitor.gd")

var player: CharacterBody3D
var status_label: Label
var hint_label: Label
var paused := false
var has_fuse := false
var power_restored := false
var has_key := false
var game_over := false
var code_panel: PanelContainer
var code_input: LineEdit
var pause_panel: PanelContainer
var settings_panel: PanelContainer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_build_input_map()
	_build_world()
	_build_hud()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if code_panel.visible:
			code_panel.visible = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		elif is_instance_valid(settings_panel) and settings_panel.visible:
			settings_panel.visible = false
			pause_panel.visible = true
			pause_panel.find_child("Button", true, false).grab_focus()
		elif not game_over:
			paused = not paused
			get_tree().paused = paused
			pause_panel.visible = paused
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if paused else Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseButton and not paused:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func set_message(message: String) -> void:
	status_label.text = message

func set_hint(message: String) -> void:
	hint_label.text = message

func _build_input_map() -> void:
	_add_key("move_forward", KEY_W)
	_add_key("move_backward", KEY_S)
	_add_key("move_left", KEY_A)
	_add_key("move_right", KEY_D)
	_add_key("sprint", KEY_SHIFT)
	_add_key("crouch", KEY_CTRL)
	_add_key("interact", KEY_E)
	_add_key("flashlight", KEY_F)
	_add_key("pause", KEY_ESCAPE)

func _add_key(action: StringName, key: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var event := InputEventKey.new()
	event.physical_keycode = key
	InputMap.action_add_event(action, event)

func _build_world() -> void:
	var builder := Node3D.new()
	builder.name = "School"
	builder.set_script(SchoolBuilder)
	add_child(builder)
	player = CharacterBody3D.new()
	player.name = "Player"
	player.set_script(PlayerController)
	player.position = Vector3(0, 0.1, 12)
	add_child(player)
	var monitor := CharacterBody3D.new()
	monitor.name = "HallMonitor"
	monitor.set_script(HallMonitor)
	monitor.position = Vector3(0, 0.1, -8)
	add_child(monitor)

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(layer)
	var center := Control.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(center)
	var crosshair := Label.new()
	crosshair.text = "+"
	crosshair.add_theme_font_size_override("font_size", 24)
	crosshair.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	crosshair.position = Vector2(-7, -16)
	center.add_child(crosshair)
	status_label = Label.new()
	status_label.text = "Find the fuse. The exit is sealed."
	status_label.position = Vector2(24, 22)
	status_label.add_theme_font_size_override("font_size", 18)
	center.add_child(status_label)
	hint_label = Label.new()
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	hint_label.position = Vector2(-180, -84)
	hint_label.size = Vector2(360, 40)
	hint_label.add_theme_font_size_override("font_size", 17)
	center.add_child(hint_label)
	var controls := Label.new()
	controls.text = "WASD move  •  Shift run  •  Ctrl crouch  •  F flashlight  •  E interact  •  Esc pause"
	controls.position = Vector2(24, 680)
	controls.add_theme_font_size_override("font_size", 13)
	center.add_child(controls)
	code_panel = PanelContainer.new()
	code_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	code_panel.position = Vector2(-170, -75)
	code_panel.size = Vector2(340, 150)
	code_panel.visible = false
	center.add_child(code_panel)
	var code_box := VBoxContainer.new()
	code_panel.add_child(code_box)
	var code_title := Label.new()
	code_title.text = "LOCKER 14 — enter the four-digit code"
	code_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	code_box.add_child(code_title)
	code_input = LineEdit.new()
	code_input.placeholder_text = "Code"
	code_input.max_length = 4
	code_input.virtual_keyboard_enabled = false
	code_input.text_submitted.connect(_submit_locker_code)
	code_box.add_child(code_input)
	var close_hint := Label.new()
	close_hint.text = "Enter to unlock  •  Esc to cancel"
	close_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	code_box.add_child(close_hint)
	_build_menus(center)

func _build_menus(parent: Control) -> void:
	pause_panel = PanelContainer.new()
	pause_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	pause_panel.position = Vector2(-180, -150)
	pause_panel.size = Vector2(360, 300)
	pause_panel.visible = false
	parent.add_child(pause_panel)
	var menu := VBoxContainer.new()
	pause_panel.add_child(menu)
	var heading := Label.new()
	heading.text = "LAST BELL — PAUSED"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu.add_child(heading)
	var resume := Button.new()
	resume.text = "Resume"
	resume.pressed.connect(_resume_game)
	menu.add_child(resume)
	var settings := Button.new()
	settings.text = "Settings"
	settings.pressed.connect(_show_settings)
	menu.add_child(settings)
	var restart := Button.new()
	restart.text = "Restart"
	restart.pressed.connect(_restart_game)
	menu.add_child(restart)
	var settings_root := PanelContainer.new()
	settings_root.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	settings_root.position = Vector2(-200, -170)
	settings_root.size = Vector2(400, 340)
	settings_root.visible = false
	parent.add_child(settings_root)
	settings_panel = settings_root
	var settings_box := VBoxContainer.new()
	settings_root.add_child(settings_box)
	var settings_heading := Label.new()
	settings_heading.text = "SETTINGS"
	settings_heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_box.add_child(settings_heading)
	var sensitivity_label := Label.new()
	sensitivity_label.text = "Mouse sensitivity"
	settings_box.add_child(sensitivity_label)
	var sensitivity_slider := HSlider.new()
	sensitivity_slider.min_value = 0.0006
	sensitivity_slider.max_value = 0.004
	sensitivity_slider.step = 0.0001
	sensitivity_slider.value = SaveManager.mouse_sensitivity
	sensitivity_slider.value_changed.connect(func(value: float) -> void: SaveManager.mouse_sensitivity = value)
	settings_box.add_child(sensitivity_slider)
	var volume_label := Label.new()
	volume_label.text = "Master volume"
	settings_box.add_child(volume_label)
	var volume_slider := HSlider.new()
	volume_slider.min_value = -36.0
	volume_slider.max_value = 0.0
	volume_slider.step = 1.0
	volume_slider.value = SaveManager.master_volume_db
	volume_slider.value_changed.connect(func(value: float) -> void:
		SaveManager.master_volume_db = value
		SaveManager._apply_settings())
	settings_box.add_child(volume_slider)
	var fullscreen_toggle := CheckButton.new()
	fullscreen_toggle.text = "Fullscreen"
	fullscreen_toggle.button_pressed = SaveManager.fullscreen
	fullscreen_toggle.toggled.connect(func(value: bool) -> void:
		SaveManager.fullscreen = value
		SaveManager._apply_settings())
	settings_box.add_child(fullscreen_toggle)
	var back := Button.new()
	back.text = "Save and return"
	back.pressed.connect(_save_and_return)
	settings_box.add_child(back)
	resume.grab_focus()

func _resume_game() -> void:
	paused = false
	get_tree().paused = false
	pause_panel.visible = false
	settings_panel.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _show_settings() -> void:
	pause_panel.visible = false
	settings_panel.visible = true
	settings_panel.find_child("HSlider", true, false).grab_focus()

func _save_and_return() -> void:
	SaveManager.save_settings()
	settings_panel.visible = false
	pause_panel.visible = true
	pause_panel.find_child("Button", true, false).grab_focus()

func _restart_game() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func show_game_over() -> void:
	if game_over:
		return
	game_over = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var overlay := ColorRect.new()
	overlay.color = Color(0.015, 0.008, 0.012, 0.94)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	status_label.get_parent().add_child(overlay)
	var message := Label.new()
	message.text = "THE HALL MONITOR FOUND YOU\n\nPress Enter to try again  •  Esc to quit"
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	message.add_theme_font_size_override("font_size", 28)
	overlay.add_child(message)

func request_locker_code() -> void:
	code_input.clear()
	code_panel.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	code_input.grab_focus()

func _submit_locker_code(code: String) -> void:
	if code == "1947":
		has_key = true
		set_message("The locker opens. Exit key collected.")
	else:
		set_message("Wrong code. The note said 1947.")
	code_panel.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if game_over and event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			get_tree().paused = false
			get_tree().reload_current_scene()
		elif event.keycode == KEY_ESCAPE:
			get_tree().quit()
