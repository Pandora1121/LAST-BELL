extends Node3D

const PlayerController = preload("res://scripts/player/player_controller.gd")
const SchoolBuilder = preload("res://scripts/levels/school_builder.gd")
const HallMonitor = preload("res://scripts/enemy/hall_monitor.gd")
const AbsentStudent = preload("res://scripts/enemy/absent_student.gd")

var player: CharacterBody3D
var status_label: Label
var objective_label: Label
var inventory_label: Label
var hint_label: Label
var paused := false
var has_fuse := false
var power_restored := false
var has_key := false
var game_over := false
var game_complete := false
var code_panel: PanelContainer
var code_input: LineEdit
var pause_panel: PanelContainer
var settings_panel: PanelContainer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_capture_mouse()
	_build_input_map()
	_build_world()
	_build_hud()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_IN and not paused and not game_over:
		_capture_mouse()

func _capture_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	# Some window managers and embedded game views release the cursor on launch.
	# A click anywhere in active gameplay should restore mouse-look immediately.
	if event is InputEventMouseButton and event.pressed and not paused and not game_over:
		_capture_mouse()
	if event is InputEventMouseMotion and not paused and not game_over and is_instance_valid(player):
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			_capture_mouse()
		player.rotate_y(-event.relative.x * SaveManager.mouse_sensitivity)
		var camera := player.get_node_or_null("Camera3D") as Camera3D
		if is_instance_valid(camera):
			camera.rotate_x(-event.relative.y * SaveManager.mouse_sensitivity)
			camera.rotation.x = clampf(camera.rotation.x, -1.48, 1.48)
	if game_over and event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			get_tree().paused = false
			get_tree().reload_current_scene()
		elif event.keycode == KEY_ESCAPE:
			get_tree().quit()

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

func set_message(message: String) -> void:
	status_label.text = message
	refresh_hud()

func refresh_hud() -> void:
	if game_complete:
		objective_label.text = "Objective complete — escape into the night."
	elif game_over:
		objective_label.text = "Caught. Restart to try the route again."
	elif not has_fuse:
		objective_label.text = "Objective: Find the fuse in the classroom alcoves."
	elif not power_restored:
		objective_label.text = "Objective: Restore power at the electrical panel."
	elif not has_key:
		objective_label.text = "Objective: Read the note and unlock locker 14."
	else:
		objective_label.text = "Objective: Unlock the exit."
	var items: Array[String] = []
	if has_fuse:
		items.append("Fuse")
	if has_key:
		items.append("Exit key")
	inventory_label.text = "Inventory: " + (", ".join(items) if not items.is_empty() else "Empty")

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
	var student := CharacterBody3D.new()
	student.name = "AbsentStudent"
	student.set_script(AbsentStudent)
	student.position = Vector3(10.2, 0.1, -3.0)
	student.set("patrol_points", [Vector3(10.2, 0.1, -3.55), Vector3(10.2, 0.1, -2.45)])
	student.set("patrol_speed", 0.95)
	student.set("chase_speed", 2.25)
	student.set("detection_range", 9.0)
	student.set("field_of_view_degrees", 82.0)
	student.set("hearing_range", 10.0)
	student.set("attack_distance", 1.2)
	add_child(student)

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
	objective_label = Label.new()
	objective_label.position = Vector2(24, 54)
	objective_label.add_theme_font_size_override("font_size", 15)
	center.add_child(objective_label)
	inventory_label = Label.new()
	inventory_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	inventory_label.position = Vector2(930, 22)
	inventory_label.size = Vector2(320, 56)
	inventory_label.add_theme_font_size_override("font_size", 15)
	center.add_child(inventory_label)
	hint_label = Label.new()
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	hint_label.position = Vector2(-180, -84)
	hint_label.size = Vector2(360, 40)
	hint_label.add_theme_font_size_override("font_size", 17)
	center.add_child(hint_label)
	var controls := Label.new()
	controls.text = "Click game to capture mouse  •  WASD move  •  Shift run  •  Ctrl crouch  •  F flashlight  •  E interact  •  Esc pause"
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
	refresh_hud()

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
	refresh_hud()
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var overlay := ColorRect.new()
	overlay.color = Color(0.015, 0.008, 0.012, 0.94)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	status_label.get_parent().add_child(overlay)
	var message := Label.new()
	message.text = "SOMETHING FOUND YOU\n\nPress Enter to try again  •  Esc to quit"
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
		AudioManager.play_sfx(&"locker")
		set_message("The locker opens. Exit key collected.")
	else:
		set_message("Wrong code. The note said 1947.")
	code_panel.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
