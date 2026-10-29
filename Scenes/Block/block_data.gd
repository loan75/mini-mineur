class_name BlockData
extends Resource

@export var name: StringName
@export var hardness: float = 1.0      # seconds to break with a power-1 pickaxe
@export var value: int = 0             # points when broken
@export var hit_sound: AudioStream
@export var particle_gradient: Gradient
