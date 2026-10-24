extends RefCounted
## Shared procedural materials for school architecture and props.

static var _templates: Dictionary = {}

static func make(surface: StringName, tint: Color) -> StandardMaterial3D:
	if not _templates.has(surface):
		_templates[surface] = _build_template(surface)
	var material: StandardMaterial3D = _templates[surface].duplicate()
	material.albedo_color = tint
	return material

static func _build_template(surface: StringName) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.roughness = 0.94
	material.uv1_triplanar = true
	material.uv1_scale = Vector3(0.45, 0.45, 0.45)
	var noise := FastNoiseLite.new()
	match surface:
		&"floor": noise.seed = 1607
		&"wall": noise.seed = 1613
		&"ceiling": noise.seed = 1621
		&"wood": noise.seed = 1627
		&"metal": noise.seed = 1637
		&"paper": noise.seed = 1657
	noise.fractal_octaves = 4
	noise.fractal_lacunarity = 2.1
	var texture := NoiseTexture2D.new()
	texture.width = 128
	texture.height = 128
	texture.noise = noise
	texture.seamless = true
	var ramp := Gradient.new()
	ramp.set_color(0, Color(0.62, 0.62, 0.62))
	ramp.set_color(1, Color(1.0, 1.0, 1.0))
	texture.color_ramp = ramp
	material.albedo_texture = texture
	match surface:
		&"floor":
			noise.frequency = 0.045
			material.roughness = 0.84
			material.uv1_scale = Vector3(0.8, 0.8, 0.8)
			material.metallic = 0.04
		&"wall":
			noise.frequency = 0.075
			material.roughness = 0.96
		&"ceiling":
			noise.frequency = 0.035
			material.roughness = 0.99
		&"wood":
			noise.frequency = 0.12
			material.roughness = 0.88
			material.uv1_scale = Vector3(0.9, 0.9, 0.9)
		&"metal":
			noise.frequency = 0.09
			material.roughness = 0.7
			material.metallic = 0.28
		&"paper":
			noise.frequency = 0.2
			material.roughness = 1.0
			material.uv1_scale = Vector3(1.4, 1.4, 1.4)
			material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	return material
