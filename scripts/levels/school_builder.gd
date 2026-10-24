extends Node3D

const SchoolMaterials = preload("res://scripts/visual/school_surface_materials.gd")

const WALL := 0
var dark_wall := Color(0.12, 0.14, 0.16)
var floor_color := Color(0.17, 0.18, 0.19)
var ceiling_color := Color(0.055, 0.065, 0.075)
var item_color := Color(0.68, 0.54, 0.26)

func _ready() -> void:
	_build_school()
	_build_interactables()
	_build_lights()

func _build_school() -> void:
	# One long corridor with classroom alcoves on both sides. Primitive geometry keeps the prototype self-contained.
	_box("CorridorFloor", Vector3(0, -0.2, 0), Vector3(8, 0.4, 42), floor_color, true)
	_box("CorridorCeiling", Vector3(0, 3.5, 0), Vector3(8, 0.25, 42), ceiling_color, true)
	# Break the corridor walls at three doorways and connect the room floors to the hall.
	_box("LeftWallEntrySegment", Vector3(-4.1, 1.6, -19.2), Vector3(0.3, 3.2, 3.6), dark_wall, true)
	_box("LeftWallMiddleSegment", Vector3(-4.1, 1.6, -3.0), Vector3(0.3, 3.2, 17.8), dark_wall, true)
	_box("LeftWallExitSegment", Vector3(-4.1, 1.6, 14.5), Vector3(0.3, 3.2, 13.0), dark_wall, true)
	_box("RightWallEntrySegment", Vector3(4.1, 1.6, -12.5), Vector3(0.3, 3.2, 17.0), dark_wall, true)
	_box("RightWallExitSegment", Vector3(4.1, 1.6, 9.5), Vector3(0.3, 3.2, 23.0), dark_wall, true)
	_box("LobbyWall", Vector3(0, 1.6, 21), Vector3(8, 3.2, 0.3), dark_wall, true)
	_box("FarWall", Vector3(0, 1.6, -21), Vector3(8, 3.2, 0.3), dark_wall, true)
	_build_side_room("ClassroomA", -1, -13.0)
	_build_side_room("TeachersRoom", 1, -3.0)
	_build_side_room("StorageRoom", -1, 7.0)
	var navigation_region := NavigationRegion3D.new()
	navigation_region.name = "SchoolNavigation"
	var navigation_mesh := NavigationMesh.new()
	navigation_mesh.agent_radius = 0.42
	navigation_mesh.cell_size = 0.2
	var nav_vertices := PackedVector3Array([
		Vector3(-3.55, 0.02, -20.5),
		Vector3(3.55, 0.02, -20.5),
		Vector3(3.55, 0.02, 20.5),
		Vector3(-3.55, 0.02, 20.5)
	])
	navigation_mesh.vertices = nav_vertices
	navigation_mesh.add_polygon(PackedInt32Array([0, 1, 2, 3]))
	var classroom_vertices := nav_vertices.size()
	nav_vertices.append_array(PackedVector3Array([
		Vector3(-11.8, 0.02, -14.0), Vector3(-3.4, 0.02, -14.0),
		Vector3(-3.4, 0.02, -12.0), Vector3(-11.8, 0.02, -12.0)
	]))
	navigation_mesh.add_polygon(PackedInt32Array([classroom_vertices, classroom_vertices + 1, classroom_vertices + 2, classroom_vertices + 3]))
	var teachers_vertices := nav_vertices.size()
	nav_vertices.append_array(PackedVector3Array([
		Vector3(3.4, 0.02, -4.0), Vector3(11.8, 0.02, -4.0),
		Vector3(11.8, 0.02, -2.0), Vector3(3.4, 0.02, -2.0)
	]))
	navigation_mesh.add_polygon(PackedInt32Array([teachers_vertices, teachers_vertices + 1, teachers_vertices + 2, teachers_vertices + 3]))
	var storage_vertices := nav_vertices.size()
	nav_vertices.append_array(PackedVector3Array([
		Vector3(-11.8, 0.02, 6.0), Vector3(-3.4, 0.02, 6.0),
		Vector3(-3.4, 0.02, 8.0), Vector3(-11.8, 0.02, 8.0)
	]))
	navigation_mesh.add_polygon(PackedInt32Array([storage_vertices, storage_vertices + 1, storage_vertices + 2, storage_vertices + 3]))
	navigation_mesh.vertices = nav_vertices
	navigation_region.navigation_mesh = navigation_mesh
	add_child(navigation_region)
	for z in [-15.0, -5.0, 5.0, 15.0]:
		var desk := _box("AbandonedDesk", Vector3(-3.1, 0.45, z), Vector3(1.4, 0.9, 0.7), Color(0.19, 0.16, 0.13), true)
		desk.rotation.y = 0.04
		_box("DeskRight", Vector3(3.1, 0.45, z + 2), Vector3(1.4, 0.9, 0.7), Color(0.19, 0.16, 0.13), true)

func _build_interactables() -> void:
	var fuse := _interactable("Fuse", Vector3(-8.1, 1.0, -13.0), Vector3(0.36, 0.2, 0.25), "[E] Pick up fuse", item_color)
	fuse.set_meta("kind", "fuse")
	var attendance_note := _interactable("AttendanceNote", Vector3(-11.55, 1.0, -13.0), Vector3(0.22, 0.3, 0.04), "[E] Read attendance slip", Color(0.65, 0.6, 0.46))
	attendance_note.set_meta("kind", "note")
	attendance_note.set_meta("message", "Attendance: Student 14 remained marked present after the last bell.")
	var maintenance_note := _interactable("MaintenanceNote", Vector3(-11.55, 1.0, 7.0), Vector3(0.22, 0.3, 0.04), "[E] Read maintenance log", Color(0.57, 0.54, 0.43))
	maintenance_note.set_meta("kind", "note")
	maintenance_note.set_meta("message", "Maintenance log: The bell rang with the power off. Nobody answered.")
	var locker := _interactable("Locker14", Vector3(8.8, 0.9, -3.0), Vector3(0.72, 1.8, 0.72), "[E] Open locker 14", Color(0.19, 0.25, 0.23))
	locker.set_meta("kind", "locker")
	var panel := _interactable("ElectricalPanel", Vector3(-3.55, 1.25, -18.0), Vector3(0.14, 1.2, 0.9), "[E] Restore power", Color(0.22, 0.24, 0.22))
	panel.set_meta("kind", "panel")
	var door := _interactable("ExitDoor", Vector3(0, 1.2, -20.0), Vector3(2.2, 2.4, 0.2), "[E] Unlock exit", Color(0.22, 0.13, 0.09))
	door.set_meta("kind", "door")
	# The note communicates the code in the environment and is optional to read.
	var note := _interactable("SmudgedNote", Vector3(7.1, 1.0, -5.0), Vector3(0.22, 0.3, 0.04), "[E] Read torn note", Color(0.64, 0.58, 0.42))
	note.set_meta("kind", "note")

func _build_side_room(room_name: String, side: int, center_z: float) -> void:
	var center_x := 8.2 * side
	_box(room_name + "Floor", Vector3(center_x, -0.2, center_z), Vector3(8.2, 0.4, 8.0), floor_color, true)
	_box(room_name + "Ceiling", Vector3(center_x, 3.5, center_z), Vector3(8.2, 0.25, 8.0), ceiling_color, true)
	_box(room_name + "OuterWall", Vector3(12.25 * side, 1.6, center_z), Vector3(0.3, 3.2, 8.0), dark_wall, true)
	_box(room_name + "NorthWall", Vector3(center_x, 1.6, center_z - 4.0), Vector3(8.2, 3.2, 0.3), dark_wall, true)
	_box(room_name + "SouthWall", Vector3(center_x, 1.6, center_z + 4.0), Vector3(8.2, 3.2, 0.3), dark_wall, true)
	if room_name != "StorageRoom":
		_box(room_name + "Desk", Vector3(center_x, 0.45, center_z + 1.0), Vector3(1.8, 0.9, 1.0), Color(0.19, 0.16, 0.13), true)
	if room_name == "ClassroomA":
		var board_z := center_z - 3.78
		_box("ClassroomChalkboard", Vector3(center_x, 2.05, board_z), Vector3(4.8, 1.25, 0.06), Color(0.055, 0.12, 0.105), false)
		_box("ChalkboardTopFrame", Vector3(center_x, 2.72, board_z + 0.04), Vector3(5.0, 0.1, 0.12), Color(0.24, 0.19, 0.14), false)
		_box("ChalkboardBottomFrame", Vector3(center_x, 1.38, board_z + 0.04), Vector3(5.0, 0.1, 0.12), Color(0.24, 0.19, 0.14), false)
		_box("ChalkboardLeftFrame", Vector3(center_x - 2.45, 2.05, board_z + 0.04), Vector3(0.1, 1.42, 0.12), Color(0.24, 0.19, 0.14), false)
		_box("ChalkboardRightFrame", Vector3(center_x + 2.45, 2.05, board_z + 0.04), Vector3(0.1, 1.42, 0.12), Color(0.24, 0.19, 0.14), false)
		_box("ChalkTraceOne", Vector3(center_x - 1.25, 2.28, board_z + 0.045), Vector3(1.15, 0.035, 0.015), Color(0.55, 0.58, 0.49), false)
		_box("ChalkTraceTwo", Vector3(center_x + 0.65, 1.9, board_z + 0.045), Vector3(1.6, 0.035, 0.015), Color(0.55, 0.58, 0.49), false)
	elif room_name == "StorageRoom":
		var shelf_z := center_z - 3.55
		for shelf_y in [0.55, 1.25, 1.95]:
			_box("StorageShelf", Vector3(center_x, shelf_y, shelf_z), Vector3(3.2, 0.12, 0.42), Color(0.2, 0.16, 0.12), false)
		for support_x in [center_x - 1.48, center_x + 1.48]:
			_box("StorageShelfSupport", Vector3(support_x, 1.2, shelf_z), Vector3(0.14, 2.2, 0.38), Color(0.16, 0.13, 0.1), false)
		_box("StorageCrate", Vector3(center_x - 0.78, 0.88, shelf_z + 0.28), Vector3(0.78, 0.48, 0.5), Color(0.32, 0.25, 0.17), false)
		_box("StorageCrate", Vector3(center_x + 0.72, 0.88, shelf_z + 0.28), Vector3(0.9, 0.48, 0.5), Color(0.27, 0.22, 0.16), false)
		_box("StorageCrate", Vector3(center_x - 0.55, 1.58, shelf_z + 0.28), Vector3(0.9, 0.48, 0.5), Color(0.3, 0.23, 0.16), false)

func _build_lights() -> void:
	var env := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.11, 0.15, 0.2)
	environment.ambient_light_energy = 0.3
	environment.fog_enabled = true
	environment.fog_light_color = Color(0.16, 0.2, 0.24)
	environment.fog_density = 0.012
	env.environment = environment
	add_child(env)
	for z in [-16.0, -6.0, 4.0, 14.0]:
		var light := OmniLight3D.new()
		light.set_script(load("res://scripts/levels/flickering_light.gd"))
		light.position = Vector3(0, 3.1, z)
		light.light_color = Color(0.58, 0.69, 0.76)
		light.light_energy = 0.72
		light.omni_range = 7.5
		light.shadow_enabled = true
		add_child(light)
	var exit_glow := OmniLight3D.new()
	exit_glow.position = Vector3(0, 2.6, -19.0)
	exit_glow.light_color = Color(0.55, 0.06, 0.035)
	exit_glow.light_energy = 1.0
	exit_glow.omni_range = 5
	add_child(exit_glow)

func _box(label: String, at: Vector3, size: Vector3, tint: Color, solid: bool) -> MeshInstance3D:
	var body := StaticBody3D.new() if solid else Node3D.new()
	body.name = label
	body.position = at
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	var material := SchoolMaterials.make(_surface_for_name(label), tint)
	mesh_instance.material_override = material
	body.add_child(mesh_instance)
	if solid:
		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		collision.shape = shape
		body.add_child(collision)
	add_child(body)
	return mesh_instance

func _interactable(label: String, at: Vector3, size: Vector3, interaction_prompt: String, tint: Color) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = label
	body.position = at
	body.set_script(load("res://scripts/interaction/prop.gd"))
	body.set("prompt", interaction_prompt)
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	var material := SchoolMaterials.make(_surface_for_name(label), tint)
	mesh_instance.material_override = material
	body.add_child(mesh_instance)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	add_child(body)
	return body

func _surface_for_name(label: String) -> StringName:
	var key := label.to_lower()
	if key.contains("floor"):
		return &"floor"
	if key.contains("ceiling"):
		return &"ceiling"
	if key.contains("desk") or key.contains("shelf") or key.contains("crate"):
		return &"wood"
	if key.contains("door"):
		return &"wood"
	if key.contains("note"):
		return &"paper"
	if key.contains("fuse") or key.contains("locker") or key.contains("panel"):
		return &"metal"
	return &"wall"
