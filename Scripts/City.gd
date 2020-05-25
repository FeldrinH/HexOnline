extends Node2D

onready var label = $Label
onready var port_sprite = $PortSprite
onready var city_sprite = $CitySprite

var manager : Node2D = null
var city_name : String

var is_port : bool = false
var is_capital : bool = false

func init(city_manager):
	manager = city_manager

func init_name(city_manager, name):
	manager = city_manager
	city_name = name
	label.text = city_name

func make_port():
	is_port = true
	port_sprite.visible = true
	city_sprite.visible = false
