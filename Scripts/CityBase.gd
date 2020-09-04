extends Node2D

var world: Node2D = null

var is_port: bool = false
var is_capital: bool = false

func init(city_manager):
	world = city_manager
