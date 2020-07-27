extends Node2D

func _input(event: InputEvent):
	if event.is_action_pressed("ui_toggle_debug_menu"):
		visible = !visible
