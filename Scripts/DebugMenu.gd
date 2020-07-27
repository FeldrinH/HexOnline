extends Node2D

func _input(event: InputEvent):
	if event.is_action_pressed("ui_toggle_debug_menu"):
		visible = !visible
		if visible:
			refresh_all()

func refresh_all():
	propagate_call("refresh")
