extends OmniLight3D
## Subtle, staggered fluorescent flicker with a stable minimum light level.

@export var interval_min := 5.0
@export var interval_max := 11.0
@export var flicker_duration := 0.14
@export var minimum_energy_ratio := 0.0

var _base_energy := 1.0
var _timer := 0.0
var _flickering := false

func _ready() -> void:
	_base_energy = light_energy
	_timer = randf_range(interval_min, interval_max)

func _process(delta: float) -> void:
	_timer -= delta
	if _timer > 0.0:
		return
	if not _flickering:
		_flickering = true
		_timer = flicker_duration
		light_energy = _base_energy * minimum_energy_ratio
	else:
		_flickering = false
		light_energy = _base_energy
		_timer = randf_range(interval_min, interval_max)
