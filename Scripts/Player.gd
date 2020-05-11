extends Node

export var id : int = -1
export var unit_color : Color

var manager : Node2D = null

func init_manager(player_manager):
	manager = player_manager
