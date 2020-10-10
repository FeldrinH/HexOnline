extends "CityBase.gd"

var player: Node = null
var conquered: bool = false

func init_capital(capital_manager, capital_player, city_name, tile):
	init(capital_manager, city_name, tile)
	is_capital = true

	player = capital_player
	player.set_capital(self)
	$Sprite.modulate = player.unit_color

func conquer(conqueror: Node):
	if conquered or conqueror == player: # Sanity checks
		return
	
	conquered = true
	
	if world.network.is_server:
		world.game.player_lost(player, conqueror)
