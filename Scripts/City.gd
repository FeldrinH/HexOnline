extends Node2D

onready var label = $Label
onready var port_icon = $PortIcon
onready var city_icon = $CityIcon
onready var city_sprite = $CitySprite

const city_tiles = [preload("res://Sprites/city_tile_1.png"), preload("res://Sprites/city_tile_2.png")]

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
	city_sprite.texture = Util.pick_random(city_tiles)
	city_sprite.rotation = rand_range(0, 360)

puppet func make_port():
	is_port = true
	port_icon.visible = true
	city_icon.visible = false
