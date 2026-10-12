extends Node

signal noise_emitted(world_position: Vector3, audible_radius: float, source: Node3D)

func report_noise(world_position: Vector3, audible_radius: float, source: Node3D) -> void:
	noise_emitted.emit(world_position, maxf(audible_radius, 0.0), source)
