extends Node

#export var id : int = -1
#export var display_name: String
export var unit_color : Color

var world : Node2D = null

var client: Node = null

func init(player_world):
	world = player_world
