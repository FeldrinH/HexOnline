extends Node2D

onready var label = $Label

var manager : Node2D = null
var city_name : String

func init(city_manager):
	manager = city_manager

func init_name(city_manager, name):
	manager = city_manager
	city_name = name
	label.text = city_name
