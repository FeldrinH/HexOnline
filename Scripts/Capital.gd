extends "CityBase.gd"

var player: Node = null
var conquered: bool = false

func init_capital(capital_manager, capital_player, city_name, tile):
	init(capital_manager, city_name, tile)
	is_capital = true

	player = capital_player
	player.set_capital(self)
	$Sprite.modulate = player.unit_color

func conquer(conquering_player):
	if conquered or conquering_player == player: # Sanity checks
		return
	
	conquered = true
	player.conquer(conquering_player)
	
	if world.network.is_server:
		world.game.check_win_conditions()
