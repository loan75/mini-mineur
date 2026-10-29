extends Node2D

@export var timer: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TimeLimit.wait_time = timer
	$TimeLimit.start()
	$TimeLimit.timeout.connect(_end)
	%Miner.energy_changed.connect(_on_miner_energy_changed)

	var rect: Rect2i = %Mine.get_used_rect()          # in cells
	var tile := Vector2(%Mine.tile_set.tile_size)
	var top_left: Vector2 = %Mine.to_global(Vector2(rect.position) * tile)
	var bottom_right: Vector2 = %Mine.to_global(Vector2(rect.end) * tile)
	var cam: Camera2D = %Camera2D
	cam.limit_left = int(top_left.x)
	cam.limit_right = int(bottom_right.x)
	cam.limit_bottom = int(bottom_right.y)

func _end() -> void:
	get_tree().paused = true
	$Miner.dead()
	%HUD.game_over()

func _on_miner_energy_changed(energy: int) -> void:
	if energy <= 0:
		_end()
