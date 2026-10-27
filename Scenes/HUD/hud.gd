extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Miner.new_score.connect(_update_score)
	%Miner.energy_changed.connect(_update_energy)
	%EnergyBar.value = %Miner.energy
	%GameOver.visible = false
	if DisplayServer.is_touchscreen_available():
		$Touchscreen.visible = true
	else:
		$Touchscreen.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	%TimerValue.text = str(int(%TimeLimit.time_left))

func _update_score(score: int) -> void:
	%ScoreValue.text = str(score)

func _update_energy(energy: int) -> void:
	%EnergyBar.value = energy

func game_over() -> void:
	%PlayerInfo.visible = false
	%FinalScore.text = %ScoreValue.text
	%GameOver.visible = true
	%GameOverSound.play()

func _unhandled_input(event: InputEvent) -> void:
	if get_tree().paused and (event is InputEventScreenTouch and event.pressed):
		get_tree().paused = false
		get_tree().reload_current_scene()
