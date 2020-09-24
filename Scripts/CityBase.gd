extends Node2D

const city_tiles = [preload("res://Sprites/city_tile_1.png"), preload("res://Sprites/city_tile_2.png"), preload("res://Sprites/city_tile_3.png"), preload("res://Sprites/city_tile_2.png"), preload("res://Sprites/city_tile_3.png"), preload("res://Sprites/city_tile_4.png"), preload("res://Sprites/city_tile_5.png"), preload("res://Sprites/city_tile_2.png"), preload("res://Sprites/city_tile_3.png"), preload("res://Sprites/city_tile_6.png"), preload("res://Sprites/city_tile_7.png"), preload("res://Sprites/city_tile_8.png")]
var world: Node2D = null
var city_name : String
var is_port: bool = false
var is_capital: bool = false
var city_tile : Node2D

onready var city_sprite = $CitySprite
onready var label = $Label

func init(city_manager, city_city_name, tile):
	world = city_manager
	city_name = city_city_name
	label.text = city_name
	city_tile = tile
	city_sprite.texture = Util.pick_random(city_tiles)
	city_sprite.rotation = rand_range(0, 360)
