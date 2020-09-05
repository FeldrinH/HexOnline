extends "CityBase.gd"

onready var label = $Label
onready var port_icon = $PortIcon
onready var city_icon = $CityIcon
onready var city_sprite = $CitySprite

const city_tiles = [preload("res://Sprites/city_tile_1.png"), preload("res://Sprites/city_tile_2.png"), preload("res://Sprites/city_tile_3.png"), preload("res://Sprites/city_tile_2.png"), preload("res://Sprites/city_tile_3.png"), preload("res://Sprites/city_tile_4.png"), preload("res://Sprites/city_tile_5.png"), preload("res://Sprites/city_tile_2.png"), preload("res://Sprites/city_tile_3.png"), preload("res://Sprites/city_tile_6.png")]

var city_name : String

func init_name(city_manager, city_city_name):
	init(city_manager)
	city_name = city_city_name
	label.text = city_name
	city_sprite.texture = Util.pick_random(city_tiles)
	city_sprite.rotation = rand_range(0, 360)

puppet func make_port():
	is_port = true
	port_icon.visible = true
	city_icon.visible = false
