extends CharacterBody3D
## Deterministic hallway FSM. Sight rays and emitted noise provide its only player cues.

enum State { PATROL, INVESTIGATE, CHASE, SEARCH, ATTACK, RETURN_TO_PATROL }

@export var patrol_speed := 1.25
@export var chase_speed := 2.7
@export var detection_range := 11.0
@export_range(20.0, 160.0) var field_of_view_degrees := 90.0
@export var hearing_range := 12.0
@export var attack_distance := 1.25
@export var search_duration := 4.0
@export var gravity := 18.0

var state := State.PATROL
var patrol_points: Array[Vector3] = [Vector3(0, 0.1, -15), Vector3(0, 0.1, 7)]
var patrol_index := 0
var last_known_position := Vector3.ZERO
var state_timer := 0.0
var player: CharacterBody3D
var sight_ray: RayCast3D
var body_mesh: MeshInstance3D
var game: Node
var navigation_agent: NavigationAgent3D
var _last_navigation_target := Vector3(INF, INF, INF)
var _attack_reported := false
var _animated_body: MeshInstance3D
var _animated_head: MeshInstance3D
var _limb_nodes: Array[MeshInstance3D] = []
var _limb_rest_rotations: Array[Quaternion] = []
var _body_rest_y := 0.0
var _animation_clock := 0.0

const BONE_MATERIAL := preload("res://scripts/visual/character_materials.gd")

func _ready() -> void:
	game = get_parent()
	player = game.player
	_build_body()
	navigation_agent = NavigationAgent3D.new()
	navigation_agent.name = "NavigationAgent3D"
	navigation_agent.path_desired_distance = 0.45
	navigation_agent.target_desired_distance = 0.7
	navigation_agent.avoidance_enabled = false
	add_child(navigation_agent)
	NoiseManager.noise_emitted.connect(_on_noise_emitted)
	_set_navigation_target(patrol_points[patrol_index])

func _build_body() -> void:
	var shape_node := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.42
	capsule.height = 1.95
	shape_node.shape = capsule
	shape_node.position.y = 0.98
	add_child(shape_node)
	_add_creature_meshes()
	if is_instance_valid(_animated_body):
		_body_rest_y = _animated_body.position.y
	for limb in _limb_nodes:
		_limb_rest_rotations.append(limb.quaternion)
	sight_ray = RayCast3D.new()
	sight_ray.enabled = true
	sight_ray.collide_with_areas = false
	add_child(sight_ray)

func _add_creature_meshes() -> void:
	# Original low crawling silhouette with pale armor, hooked limbs and hanging tissue.
	_animated_body = _add_ellipsoid("Ribbed torso", Vector3(0, 0.83, 0.05), Vector3(0.88, 0.42, 1.25), BONE_MATERIAL.bone())
	_add_ellipsoid("Shoulder carapace", Vector3(0, 1.12, -0.63), Vector3(0.76, 0.34, 0.64), BONE_MATERIAL.bone())
	_animated_head = _add_ellipsoid("Skull", Vector3(0, 1.32, -1.18), Vector3(0.56, 0.48, 0.5), BONE_MATERIAL.bone())
	_add_ellipsoid("Mandible", Vector3(0, 0.99, -1.52), Vector3(0.27, 0.34, 0.52), BONE_MATERIAL.flesh())
	for side in [-1.0, 1.0]:
		_add_ellipsoid("Socket", Vector3(side * 0.31, 1.43, -1.48), Vector3(0.12, 0.09, 0.07), BONE_MATERIAL.flesh())
		_add_limb(Vector3(side * 0.58, 1.03, -0.72), Vector3(side * 1.13, 0.54, -1.16), 0.22, BONE_MATERIAL.bone())
		_add_limb(Vector3(side * 1.13, 0.54, -1.16), Vector3(side * 1.28, 0.12, -1.7), 0.13, BONE_MATERIAL.bone())
		_add_limb(Vector3(side * 0.62, 0.76, 0.62), Vector3(side * 1.0, 0.45, 1.15), 0.19, BONE_MATERIAL.flesh())
		_add_limb(Vector3(side * 1.0, 0.45, 1.15), Vector3(side * 1.18, 0.1, 1.55), 0.12, BONE_MATERIAL.bone())
		_add_limb(Vector3(side * 0.38, 1.38, -0.92), Vector3(side * 0.2, 2.05, -0.62), 0.12, BONE_MATERIAL.bone())
		_add_limb(Vector3(side * 0.2, 2.05, -0.62), Vector3(side * 0.46, 2.42, -0.24), 0.075, BONE_MATERIAL.bone())
	for index in range(5):
		var x := -0.62 + index * 0.31
		_add_limb(Vector3(x, 0.72, 0.55), Vector3(x * 1.25, 0.2, 1.35 + (index % 2) * 0.25), 0.055, BONE_MATERIAL.flesh())
	var eye := OmniLight3D.new()
	eye.position = Vector3(0, 1.48, -1.55)
	eye.light_color = Color(0.65, 0.025, 0.018)
	eye.light_energy = 0.42
	eye.omni_range = 1.4
	add_child(eye)

func _add_ellipsoid(node_name: String, at: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.name = node_name
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	part.mesh = mesh
	part.position = at
	part.scale = size * 2.0
	part.material_override = material
	add_child(part)
	return part

func _add_limb(from: Vector3, to: Vector3, radius: float, material: Material) -> void:
	var limb := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius * 0.55
	mesh.bottom_radius = radius
	mesh.height = 1.0
	limb.mesh = mesh
	limb.position = (from + to) * 0.5
	limb.scale.y = from.distance_to(to)
	limb.quaternion = Quaternion(Vector3.UP, (to - from).normalized())
	limb.material_override = material
	add_child(limb)
	_limb_nodes.append(limb)

func _process(delta: float) -> void:
	if get_tree().paused:
		return
	_animation_clock += delta
	var motion_amount := 1.0 if state == State.CHASE else 0.55
	if is_instance_valid(_animated_body):
		_animated_body.position.y = _body_rest_y + sin(_animation_clock * 2.2) * 0.018 * motion_amount
	if is_instance_valid(_animated_head):
		_animated_head.rotation.x = sin(_animation_clock * 1.4) * 0.025 * motion_amount
		_animated_head.rotation.y = sin(_animation_clock * 0.7) * 0.045 * motion_amount
	for index in range(_limb_nodes.size()):
		_limb_nodes[index].quaternion = _limb_rest_rotations[index] * Quaternion(Vector3.FORWARD, sin(_animation_clock * 3.1 + index * 1.7) * 0.022 * motion_amount)

func _physics_process(delta: float) -> void:
	if get_tree().paused or not is_instance_valid(player):
		return
	state_timer = maxf(state_timer - delta, 0.0)
	var can_see_player := _can_see_player()
	if can_see_player:
		last_known_position = player.global_position
		if state != State.CHASE:
			state = State.CHASE
	elif state == State.CHASE and state_timer <= 0.0:
		state = State.SEARCH
		state_timer = search_duration
	elif state == State.SEARCH and state_timer <= 0.0:
		state = State.RETURN_TO_PATROL
	elif state == State.RETURN_TO_PATROL and global_position.distance_to(patrol_points[patrol_index]) < 0.8:
		state = State.PATROL

	if state == State.PATROL:
		_move_toward(patrol_points[patrol_index], patrol_speed, delta)
		if global_position.distance_to(patrol_points[patrol_index]) < 0.8:
			patrol_index = (patrol_index + 1) % patrol_points.size()
	elif state == State.INVESTIGATE:
		_move_toward(last_known_position, patrol_speed * 1.2, delta)
		if global_position.distance_to(last_known_position) < 0.9:
			state = State.SEARCH
			state_timer = search_duration
	elif state == State.CHASE:
		state_timer = 1.4
		if global_position.distance_to(player.global_position) <= attack_distance:
			state = State.ATTACK
		else:
			_move_toward(last_known_position, chase_speed, delta)
	elif state == State.SEARCH:
		# Search locally around the last position instead of tracking through walls.
		var search_offset := Vector3(sin(Time.get_ticks_msec() * 0.001) * 1.5, 0, cos(Time.get_ticks_msec() * 0.001) * 1.5)
		_move_toward(last_known_position + search_offset, patrol_speed, delta)
	elif state == State.ATTACK:
		if not _attack_reported:
			_attack_reported = true
			game.show_game_over()
	elif state == State.RETURN_TO_PATROL:
		_move_toward(patrol_points[patrol_index], patrol_speed, delta)
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0
	move_and_slide()

func _can_see_player() -> bool:
	var to_player := player.global_position + Vector3.UP - global_position
	var distance := to_player.length()
	if distance > detection_range or distance < 0.01:
		return false
	var forward := -global_transform.basis.z
	if rad_to_deg(forward.angle_to(to_player.normalized())) > field_of_view_degrees * 0.5:
		return false
	sight_ray.target_position = to_local(player.global_position + Vector3.UP * 1.1)
	sight_ray.force_raycast_update()
	return not sight_ray.is_colliding() or sight_ray.get_collider() == player

func _move_toward(destination: Vector3, speed: float, delta: float) -> void:
	_set_navigation_target(destination)
	var offset := destination - global_position
	if not navigation_agent.is_navigation_finished():
		var next_position := navigation_agent.get_next_path_position()
		if next_position.distance_to(global_position) > 0.05:
			offset = next_position - global_position
	offset.y = 0.0
	var direction := offset.normalized()
	velocity.x = move_toward(velocity.x, direction.x * speed, speed * 3.0 * delta)
	velocity.z = move_toward(velocity.z, direction.z * speed, speed * 3.0 * delta)
	if direction.length() > 0.01:
		look_at(global_position + direction, Vector3.UP)

func _set_navigation_target(destination: Vector3) -> void:
	if _last_navigation_target.distance_to(destination) > 0.6:
		_last_navigation_target = destination
		navigation_agent.target_position = destination

func _on_noise_emitted(world_position: Vector3, audible_radius: float, source: Node3D) -> void:
	if source == self or state == State.CHASE or state == State.ATTACK:
		return
	var hearing_distance := minf(audible_radius, hearing_range)
	if global_position.distance_to(world_position) > hearing_distance:
		return
	last_known_position = world_position
	state = State.INVESTIGATE
	state_timer = search_duration
	_set_navigation_target(world_position)
