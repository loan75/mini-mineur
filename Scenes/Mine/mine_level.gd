extends Node2D

@export var timer: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TimeLimit.wait_time = timer
	$TimeLimit.start()
	$TimeLimit.timeout.connect(_end)
	%Miner.energy_changed.connect(_on_miner_energy_changed)

func _end() -> void:
	get_tree().paused = true
	$Miner.dead()
	%HUD.game_over()

func _on_miner_energy_changed(energy: int) -> void:
	if energy <= 0:
		_end()
