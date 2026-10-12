extends Node3D

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
	_box("LeftHallWall", Vector3(-4.1, 1.6, 0), Vector3(0.3, 3.2, 42), dark_wall, true)
	_box("RightHallWall", Vector3(4.1, 1.6, 0), Vector3(0.3, 3.2, 42), dark_wall, true)
	_box("LobbyWall", Vector3(0, 1.6, 21), Vector3(8, 3.2, 0.3), dark_wall, true)
	_box("FarWall", Vector3(0, 1.6, -21), Vector3(8, 3.2, 0.3), dark_wall, true)
	var navigation_region := NavigationRegion3D.new()
	navigation_region.name = "SchoolNavigation"
	var navigation_mesh := NavigationMesh.new()
	navigation_mesh.agent_radius = 0.42
	navigation_mesh.cell_size = 0.2
	navigation_mesh.vertices = PackedVector3Array([
		Vector3(-3.55, 0.02, -20.5),
		Vector3(3.55, 0.02, -20.5),
		Vector3(3.55, 0.02, 20.5),
		Vector3(-3.55, 0.02, 20.5)
	])
	navigation_mesh.add_polygon(PackedInt32Array([0, 1, 2, 3]))
	navigation_region.navigation_mesh = navigation_mesh
	add_child(navigation_region)
	for z in [-13.0, -3.0, 7.0]:
		# Short returns create readable room-like alcoves off the main hall.
		_box("ClassroomLeftReturn", Vector3(-2.6, 1.6, z), Vector3(3.0, 3.2, 0.22), dark_wall, true)
		_box("ClassroomRightReturn", Vector3(2.6, 1.6, z), Vector3(3.0, 3.2, 0.22), dark_wall, true)
	for z in [-15.0, -5.0, 5.0, 15.0]:
		var desk := _box("AbandonedDesk", Vector3(-3.1, 0.45, z), Vector3(1.4, 0.9, 0.7), Color(0.19, 0.16, 0.13), true)
		desk.rotation.y = 0.04
		_box("DeskRight", Vector3(3.1, 0.45, z + 2), Vector3(1.4, 0.9, 0.7), Color(0.19, 0.16, 0.13), true)

func _build_interactables() -> void:
	var fuse := _interactable("Fuse", Vector3(-2.3, 0.35, -12.5), Vector3(0.36, 0.2, 0.25), "[E] Pick up fuse", item_color)
	fuse.set_meta("kind", "fuse")
	var locker := _interactable("Locker14", Vector3(2.75, 0.9, 1.0), Vector3(0.72, 1.8, 0.72), "[E] Open locker 14", Color(0.19, 0.25, 0.23))
	locker.set_meta("kind", "locker")
	var panel := _interactable("ElectricalPanel", Vector3(-3.55, 1.25, -18.0), Vector3(0.14, 1.2, 0.9), "[E] Restore power", Color(0.22, 0.24, 0.22))
	panel.set_meta("kind", "panel")
	var door := _interactable("ExitDoor", Vector3(0, 1.2, -20.0), Vector3(2.2, 2.4, 0.2), "[E] Unlock exit", Color(0.22, 0.13, 0.09))
	door.set_meta("kind", "door")
	# The note communicates the code in the environment and is optional to read.
	var note := _interactable("SmudgedNote", Vector3(2.35, 1.0, -7.0), Vector3(0.22, 0.3, 0.04), "[E] Read torn note", Color(0.64, 0.58, 0.42))
	note.set_meta("kind", "note")

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
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.roughness = 0.92
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
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.roughness = 0.85
	mesh_instance.material_override = material
	body.add_child(mesh_instance)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	add_child(body)
	return body
