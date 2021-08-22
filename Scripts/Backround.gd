extends Node2D

const ArmyUnit = preload("res://ArmyUnit.tscn")
const HexTile = preload("res://HexTile.tscn")
const MapGenerator = preload("res://Scripts/MapGenerator.gd")
const MapSender = preload("res://Scripts/MapSender.gd")

onready var forestsprites : Node2D = $ForestSpritesContainer
onready var tiles : Node2D = $TilesContainer
onready var tilemap : TileMap = $TileMap

const __tile_dict : Dictionary = {}
const __tile_array : Array = []

const game : Dictionary = {"players": []}

func _ready():
	randomize()
	for coord in tilemap.get_used_cells():
		var tile_index = tilemap.get_cellv(coord)
		var tile_instance = HexTile.instance()
		var hex_coord = Vector2(coord.x * 2 + posmod(coord.y, 2), coord.y)
		
		__tile_dict[hex_coord] = tile_instance
		__tile_array.append(tile_instance)
		tile_instance.init(self, hex_coord, tilemap.map_to_world(coord) + tilemap.position, tile_index == 1, len(__tile_array)-1)
		tile_instance.set_name(str(hex_coord))
		
		tiles.add_child(tile_instance)
	
	tilemap.queue_free()
	
	yield(generate_map(), "completed")
	
	for tile in get_all_tiles():
		if tile.city:
			tile.city.city_icon.visible = false
			tile.city.port_icon.visible = false
			tile.city.label.visible = false

	

func get_tile(coord):
	return __tile_dict.get(coord, null)

func get_all_tiles():
	return __tile_array

puppet func setup_tiles_appearance():
	for tile in __tile_array:
		tile.setup_appearance()

func get_capital_tiles():
	return []

func generate_map():
	var mapgen_coroutine = MapGenerator.generate_map(self)
	while mapgen_coroutine is GDScriptFunctionState and mapgen_coroutine.is_valid():
		setup_tiles_appearance()
		yield(get_tree(), "idle_frame")
		mapgen_coroutine = mapgen_coroutine.resume()
	setup_tiles_appearance()

func find_neighbours(center_tile) -> Array:
	var neigbours : Array = []
	
	var center_coordinate : Vector2 = center_tile.coord
	for dir in Util.directions:
		var new_tile = get_tile(center_coordinate + dir)
		if new_tile != null:
			neigbours.append(new_tile)
	
	return neigbours

func clear_map():
	for tile in get_all_tiles():
		if tile.city:
			tile.remove_city()
		tile.army = null
	
