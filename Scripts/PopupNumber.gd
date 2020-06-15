extends Node2D

onready var label : Label = $LabelContainer/Label
onready var animator : AnimationPlayer = $AnimationPlayer

func play_popup(number : int, color : Color, anchor_position : Vector2):
	position = anchor_position
	modulate = color
	label.text = ("+" if sign(number) > 0 else "") + str(number)
	#animator.stop(true)
	animator.play("Popup")
