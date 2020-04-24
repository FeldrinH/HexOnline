extends Node2D

const tile_scene = preload("res://HexTile.tscn")

onready var tilemap : TileMap = $"../TileMap"

const tile_dict = {}

func _ready():
	for coordinate in tilemap.get_used_cells():
		var tile_instance = tile_scene.instance()
		tile_instance.set_position(tilemap.map_to_world(coordinate))

		coordinate.x *= 2
		tile_dict[coordinate] = tile_instance
		tile_instance.coordinate = coordinate
		tile_instance.set_name(str(coordinate))

		add_child(tile_instance)

	tilemap.queue_free()
