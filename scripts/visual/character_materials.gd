extends RefCounted
## Shared procedural surface materials for the original character meshes.

static var _bone: StandardMaterial3D
static var _flesh: StandardMaterial3D
static var _uniform: StandardMaterial3D
static var _skin: StandardMaterial3D

static func _surface(base: Color, noise_scale: float, rough: float, metallic: float = 0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = base
	mat.roughness = rough
	mat.metallic = metallic
	var noise := FastNoiseLite.new()
	noise.seed = 1847
	noise.frequency = noise_scale
	noise.fractal_octaves = 4
	var texture := NoiseTexture2D.new()
	texture.width = 128
	texture.height = 128
	texture.noise = noise
	texture.seamless = true
	var ramp := Gradient.new()
	ramp.set_color(0, Color(0.46, 0.46, 0.46))
	ramp.set_color(1, Color(1.0, 1.0, 1.0))
	texture.color_ramp = ramp
	mat.albedo_texture = texture
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	return mat

static func bone() -> StandardMaterial3D:
	if _bone == null:
		_bone = _surface(Color(0.68, 0.66, 0.59), 0.055, 0.84)
	return _bone

static func flesh() -> StandardMaterial3D:
	if _flesh == null:
		_flesh = _surface(Color(0.075, 0.045, 0.052), 0.09, 0.98)
	return _flesh

static func uniform() -> StandardMaterial3D:
	if _uniform == null:
		_uniform = _surface(Color(0.055, 0.075, 0.09), 0.035, 0.94)
	return _uniform

static func skin() -> StandardMaterial3D:
	if _skin == null:
		_skin = _surface(Color(0.55, 0.43, 0.39), 0.08, 0.9)
	return _skin
