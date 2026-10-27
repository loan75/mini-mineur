extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Miner.new_score.connect(_update_score)
	%Miner.energy_reduce.connect(_update_energy)
	%EnergyBar.value = 100
	%GameOver.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	%TimerValue.text = str(int(%TimeLimit.time_left))
	_retry()

func _update_score(score: int) -> void:
	%ScoreValue.text = str(score)

func _update_energy(energy: int) -> void:
	%EnergyBar.value = energy

func game_over() -> void:
	%PlayerInfo.visible = false
	%FinalScore.text = %ScoreValue.text
	%GameOver.visible = true

func _retry() -> void:
	if get_tree().paused and (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("mining")):
		get_tree().paused = false
		get_tree().reload_current_scene()
