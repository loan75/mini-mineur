extends CanvasLayer

func _ready() -> void:
	if DisplayServer.is_touchscreen_available():
		$PC.visible = false
		$Touchscreen.visible = true
	else:
		$PC.visible = true
		$Touchscreen.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("confirm"):
		get_tree().change_scene_to_file("uid://bs7bdu8p5owmo")
	if event is InputEventScreenTouch and event.pressed:
		get_tree().change_scene_to_file("uid://bs7bdu8p5owmo")
