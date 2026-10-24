extends CharacterBody3D

const CharacterMaterials = preload("res://scripts/visual/character_materials.gd")

@export var walk_speed := 3.2
@export var sprint_speed := 5.6
@export var crouch_speed := 1.65
@export var mouse_sensitivity := 0.0018
@export var acceleration := 12.0
@export var gravity := 18.0
@export var interaction_distance := 2.6

var camera: Camera3D
var ray: RayCast3D
var flashlight: SpotLight3D
var hands_rig: Node3D
var crouching := false
var world: Node
var footstep_timer := 0.0

func _ready() -> void:
	world = get_parent()
	_build_body()

func _build_body() -> void:
	var collider := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.34
	capsule.height = 1.7
	collider.shape = capsule
	collider.position.y = 0.85
	add_child(collider)
	camera = Camera3D.new()
	camera.name = "Camera3D"
	camera.position.y = 1.55
	camera.current = true
	add_child(camera)
	ray = RayCast3D.new()
	ray.target_position = Vector3(0, 0, -interaction_distance)
	ray.collide_with_areas = true
	ray.enabled = true
	camera.add_child(ray)
	flashlight = SpotLight3D.new()
	flashlight.name = "Flashlight"
	flashlight.light_energy = 3.2
	flashlight.spot_range = 18.0
	flashlight.spot_angle = 38.0
	flashlight.shadow_enabled = true
	camera.add_child(flashlight)
	_build_first_person_hands()

func _build_first_person_hands() -> void:
	hands_rig = Node3D.new()
	hands_rig.name = "FirstPersonHands"
	camera.add_child(hands_rig)
	for side in [-1.0, 1.0]:
		var sleeve := MeshInstance3D.new()
		var sleeve_mesh := CapsuleMesh.new()
		sleeve_mesh.radius = 0.115
		sleeve_mesh.height = 0.74
		sleeve.mesh = sleeve_mesh
		sleeve.position = Vector3(side * 0.31, -0.43, -0.68)
		sleeve.rotation.z = side * -0.34
		sleeve.material_override = CharacterMaterials.uniform()
		hands_rig.add_child(sleeve)
		var cuff := MeshInstance3D.new()
		var cuff_mesh := CylinderMesh.new()
		cuff_mesh.top_radius = 0.118
		cuff_mesh.bottom_radius = 0.118
		cuff_mesh.height = 0.12
		cuff.mesh = cuff_mesh
		cuff.position = Vector3(side * 0.25, -0.66, -0.68)
		cuff.rotation.z = side * -0.34
		cuff.material_override = CharacterMaterials.bone()
		hands_rig.add_child(cuff)
		var hand := MeshInstance3D.new()
		var hand_mesh := SphereMesh.new()
		hand_mesh.radius = 0.11
		hand_mesh.height = 0.2
		hand.mesh = hand_mesh
		hand.position = Vector3(side * 0.23, -0.77, -0.76)
		hand.scale = Vector3(0.9, 1.15, 0.7)
		hand.material_override = CharacterMaterials.skin()
		hands_rig.add_child(hand)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("flashlight"):
		flashlight.visible = not flashlight.visible
	if event.is_action_pressed("interact"):
		_interact()

func _physics_process(delta: float) -> void:
	if get_tree().paused:
		return
	crouching = Input.is_action_pressed("crouch")
	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_vector.x, 0, input_vector.y)).normalized()
	var speed := crouch_speed if crouching else (sprint_speed if Input.is_action_pressed("sprint") else walk_speed)
	velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)
	velocity.z = move_toward(velocity.z, direction.z * speed, acceleration * delta)
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0
	move_and_slide()
	if direction.length() > 0.1:
		footstep_timer -= delta
		if footstep_timer <= 0.0:
			var noise_radius := 2.0 if crouching else (13.0 if speed == sprint_speed else 5.0)
			NoiseManager.report_noise(global_position, noise_radius, self)
			if is_on_floor() and Vector2(velocity.x, velocity.z).length() > 0.2:
				var step_pitch := randf_range(0.96, 1.04)
				var step_volume := -5.0 if crouching else (1.0 if speed == sprint_speed else -1.5)
				if crouching:
					step_pitch *= 0.88
				elif speed == sprint_speed:
					step_pitch *= 1.12
				AudioManager.play_sfx(&"footstep", step_pitch, step_volume)
			footstep_timer = 0.7 if crouching else (0.42 if speed == sprint_speed else 0.58)
	else:
		footstep_timer = 0.0

func _interact() -> void:
	ray.force_raycast_update()
	if not ray.is_colliding():
		world.set_message("Nothing within reach.")
		return
	var target := ray.get_collider()
	if target.has_method("interact"):
		target.interact(self, world)

func _process(delta: float) -> void:
	if is_instance_valid(hands_rig):
		var moving := not get_tree().paused and is_on_floor() and Vector2(velocity.x, velocity.z).length() > 0.2
		var bob_rate := 13.0 if Input.is_action_pressed("sprint") else 9.0
		var bob := sin(Time.get_ticks_msec() * 0.001 * bob_rate) * 0.018 if moving else 0.0
		hands_rig.position.y = move_toward(hands_rig.position.y, bob, delta * 0.16)
	if not is_instance_valid(world) or not is_instance_valid(ray):
		return
	ray.force_raycast_update()
	if ray.is_colliding():
		var target := ray.get_collider()
		world.set_hint("[E] " + str(target.get("prompt")) if target.has_method("interact") else "")
	else:
		world.set_hint("")
