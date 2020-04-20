extends Node2D

const tile_scene = preload("res://HexTile.tscn")

onready var tilemap : TileMap = $"../TileMap"

func _ready():
	for tile in tilemap.get_used_cells():
		var tile_instance = tile_scene.instance()
		tile_instance.set_position(tilemap.map_to_world(tile))
		tile_instance.set_name(str(tile))
		add_child(tile_instance)
