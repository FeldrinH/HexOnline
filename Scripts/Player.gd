extends Node

export var id : int = -1
export var unit_color : Color

var manager : Node2D = null

func init_manager(game_manager):
	manager = game_manager
