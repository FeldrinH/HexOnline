extends "CityBase.gd"

var player: Node = null
var conquered: bool = false

func init_capital(capital_manager, capital_player, city_name):
	init(capital_manager, city_name)
	is_capital = true
	
	player = capital_player
	player.set_capital(self)
	$Sprite.modulate = player.unit_color
	
	world.connect("turn_start", self, "__turn_start")

func conquer(conquering_player):
	if conquered or conquering_player == player: # Sanity checks
		return
	
	conquered = true
	player.conquer(conquering_player)

func __turn_start():
	pass
