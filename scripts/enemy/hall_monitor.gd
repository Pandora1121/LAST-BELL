extends CharacterBody3D
## Simple deterministic hallway FSM. Walls block visual detection; the monster never teleports to the player.

enum State { PATROL, INVESTIGATE, CHASE, SEARCH, ATTACK, RETURN_TO_PATROL }

@export var patrol_speed := 1.25
@export var chase_speed := 2.7
@export var detection_range := 11.0
@export_range(20.0, 160.0) var field_of_view_degrees := 90.0
@export var hearing_range := 8.0
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

func _ready() -> void:
	game = get_parent()
	player = game.player
	_build_body()

func _build_body() -> void:
	var shape_node := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.42
	capsule.height = 1.95
	shape_node.shape = capsule
	shape_node.position.y = 0.98
	add_child(shape_node)
	body_mesh = MeshInstance3D.new()
	var mesh := CapsuleMesh.new()
	mesh.radius = 0.42
	mesh.height = 1.95
	body_mesh.mesh = mesh
	body_mesh.position.y = 0.98
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.018, 0.024, 0.03)
	material.roughness = 0.95
	body_mesh.material_override = material
	add_child(body_mesh)
	var eye := OmniLight3D.new()
	eye.position = Vector3(0, 1.58, -0.32)
	eye.light_color = Color(0.65, 0.025, 0.018)
	eye.light_energy = 0.65
	eye.omni_range = 2.0
	add_child(eye)
	sight_ray = RayCast3D.new()
	sight_ray.enabled = true
	sight_ray.collide_with_areas = false
	add_child(sight_ray)

func _physics_process(delta: float) -> void:
	if get_tree().paused or not is_instance_valid(player):
		return
	state_timer = maxf(state_timer - delta, 0.0)
	var can_see_player := _can_see_player()
	if can_see_player:
		last_known_position = player.global_position
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
		game.show_game_over()
	elif state == State.RETURN_TO_PATROL:
		_move_toward(patrol_points[patrol_index], patrol_speed, delta)
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0
	move_and_slide()

func _can_see_player() -> bool:
	var to_player := player.global_position + Vector3.UP - global_position - Vector3.UP
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
	var offset := destination - global_position
	offset.y = 0.0
	var direction := offset.normalized()
	velocity.x = move_toward(velocity.x, direction.x * speed, speed * 3.0 * delta)
	velocity.z = move_toward(velocity.z, direction.z * speed, speed * 3.0 * delta)
	if direction.length() > 0.01:
		look_at(global_position + direction, Vector3.UP)
