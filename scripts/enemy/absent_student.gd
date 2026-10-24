extends "res://scripts/enemy/hall_monitor.gd"
## A missing student: a quiet, masked humanoid who guards the teachers' room.

const CharacterMaterials = preload("res://scripts/visual/character_materials.gd")

func _add_creature_meshes() -> void:
	var cloth := CharacterMaterials.uniform()
	var skin := CharacterMaterials.skin()
	var dark := CharacterMaterials.flesh()
	_animated_body = _add_ellipsoid("Torn jacket", Vector3(0, 1.02, 0), Vector3(0.43, 0.48, 0.25), cloth)
	_add_ellipsoid("Collar", Vector3(0, 1.4, -0.01), Vector3(0.25, 0.12, 0.22), dark)
	_animated_head = _add_ellipsoid("Masked face", Vector3(0, 1.72, -0.02), Vector3(0.27, 0.34, 0.25), skin)
	_add_ellipsoid("Cracked mask", Vector3(0, 1.75, -0.22), Vector3(0.23, 0.25, 0.08), CharacterMaterials.bone())
	_add_ellipsoid("Mask eye slit", Vector3(0, 1.79, -0.3), Vector3(0.16, 0.035, 0.018), dark)
	for side in [-1.0, 1.0]:
		_add_limb(Vector3(side * 0.32, 1.32, 0), Vector3(side * 0.48, 0.88, -0.05), 0.13, cloth)
		_add_limb(Vector3(side * 0.48, 0.88, -0.05), Vector3(side * 0.43, 0.38, -0.15), 0.09, skin)
		_add_ellipsoid("Hand", Vector3(side * 0.43, 0.27, -0.18), Vector3(0.11, 0.18, 0.09), skin)
		_add_limb(Vector3(side * 0.2, 0.75, 0), Vector3(side * 0.23, 0.38, 0.04), 0.14, cloth)
		_add_ellipsoid("Shoe", Vector3(side * 0.23, 0.12, -0.12), Vector3(0.16, 0.12, 0.27), dark)
	var eye := OmniLight3D.new()
	eye.position = Vector3(0, 1.78, -0.35)
	eye.light_color = Color(0.52, 0.04, 0.025)
	eye.light_energy = 0.22
	eye.omni_range = 0.8
	add_child(eye)
