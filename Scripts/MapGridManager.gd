extends Node2D

const tile_scene = preload("res://HexTile.tscn")

onready var tilemap : TileMap = $"../TileMap"

const tile_dict = {}
var active_tile = null

func _ready():
	print(posmod(-3, 2))
	
	for coordinate in tilemap.get_used_cells():
		var tile_instance = tile_scene.instance()
		tile_instance.set_position(tilemap.map_to_world(coordinate))

		coordinate.x = coordinate.x * 2 + posmod(coordinate.y, 2)
		tile_dict[coordinate] = tile_instance
		tile_instance.coordinate = coordinate
		tile_instance.set_name(str(coordinate))

		add_child(tile_instance)

	tilemap.queue_free()

func get_tile(coord):
	return tile_dict[coord]
