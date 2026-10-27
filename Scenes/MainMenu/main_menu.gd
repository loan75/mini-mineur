extends CanvasLayer

func _ready() -> void:
	if DisplayServer.is_touchscreen_available():
		$PC.visible = false
		$Touchscreen.visible = true
	else:
		$PC.visible = true
		$Touchscreen.visible = false

# hud.gd
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		get_tree().change_scene_to_file("uid://bs7bdu8p5owmo")
	if event is InputEventScreenTouch:
		get_tree().change_scene_to_file("uid://bs7bdu8p5owmo")
