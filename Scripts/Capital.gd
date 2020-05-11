extends "City.gd"

var player : Node = null

func init_capital(main_manager, side):
	init(main_manager)
	player = side
	$Sprite.modulate = side.unit_color
	
	manager.connect("turn_start", self, "__turn_start")

func __turn_start():
	pass
