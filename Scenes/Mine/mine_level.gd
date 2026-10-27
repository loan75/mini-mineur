extends Node2D

@export var timer: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TimeLimit.wait_time = timer
	$TimeLimit.start()
	$TimeLimit.timeout.connect(_end)
	%Miner.energy_reduce.connect(is_energy_empty)

func _end() -> void:
	get_tree().paused = true
	$Miner.dead()
	$HUD.game_over()

func is_energy_empty(energy: int) -> void:
	if energy <= 0:
		_end()
