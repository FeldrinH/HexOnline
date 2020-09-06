extends Node

#export var id : int = -1
#export var display_name: String
export var unit_color : Color

var world : Node2D = null

var id: int = -1
var client_id: int = -1
var capital: Node2D = null

func init(player_world, player_id):
	world = player_world
	id = player_id

func set_capital(new_capital):
	capital = new_capital

func conquer(conquering_player):
	for tile in world.get_all_tiles():
		if tile.player == self:
			tile.try_occupy(conquering_player)
