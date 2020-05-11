extends "City.gd"

var player : Node = null

func init_capital(capital_manager, capital_player):
	init(capital_manager)
	player = capital_player
	$Sprite.modulate = capital_player.unit_color
	
	manager.connect("turn_start", self, "__turn_start")

func __turn_start():
	pass
