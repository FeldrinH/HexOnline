extends Node

#export var id : int = -1
#export var display_name: String
export var unit_color : Color

var world : Node2D = null

var id: int = -1
var client: Node = null

func init(player_world, player_id):
	world = player_world
	id = player_id
