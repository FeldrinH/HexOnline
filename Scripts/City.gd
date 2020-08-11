extends Node2D

onready var label = $Label
onready var port_sprite = $PortSprite
onready var city_sprite = $CitySprite

var world : Node2D = null
var city_name : String

var is_port : bool = false
var is_capital : bool = false

func init(city_manager):
	world = city_manager

func init_name(city_manager, city_city_name):
	world = city_manager
	city_name = city_city_name
	label.text = city_name

puppet func make_port():
	is_port = true
	port_sprite.visible = true
	city_sprite.visible = false
