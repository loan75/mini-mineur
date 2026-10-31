class_name HUD
extends CanvasLayer
## Display only: the level pushes values in, the HUD shows them.

signal retry_requested


func _ready() -> void:
	%GameOver.visible = false
	$Touchscreen.visible = DisplayServer.is_touchscreen_available()


func setup(max_energy: int) -> void:
	%EnergyBar.max_value = max_energy
	%EnergyBar.value = max_energy
	set_score(0)


func set_score(score: int) -> void:
	%ScoreValue.text = str(score)


func set_energy(energy: int) -> void:
	%EnergyBar.value = energy


func set_time(seconds_left: float) -> void:
	%TimerValue.text = str(int(seconds_left))


func show_game_over(score: int) -> void:
	%PlayerInfo.visible = false
	%FinalScore.text = str(score)
	%GameOver.visible = true
	%GameOverSound.play()


func _unhandled_input(event: InputEvent) -> void:
	if not %GameOver.visible:
		return
	if event.is_action_pressed("confirm") or (event is InputEventScreenTouch and event.pressed):
		retry_requested.emit()
