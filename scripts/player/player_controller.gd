extends CharacterBody3D

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

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var sensitivity: float = SaveManager.mouse_sensitivity
		rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clampf(camera.rotation.x, -1.48, 1.48)
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

func _process(_delta: float) -> void:
	if not is_instance_valid(world) or not is_instance_valid(ray):
		return
	ray.force_raycast_update()
	if ray.is_colliding():
		var target := ray.get_collider()
		world.set_hint("[E] " + str(target.get("prompt")) if target.has_method("interact") else "")
	else:
		world.set_hint("")
