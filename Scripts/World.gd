extends Node2D

signal turn_start(starting_player)
signal turn_end(ending_player)
signal unit_enter(unit)

const ArmyUnit = preload("res://ArmyUnit.tscn")
const HexTile = preload("res://HexTile.tscn")
const MapGenerator = preload("res://Scripts/MapGenerator.gd")
#const TerrainGroundSprite = preload("res://TerrainGroundSprite.tscn")
#const TerrainGroundTextures = [preload("res://Sprites/Terrain/hex_sprites_blend_1.png"), preload("res://Sprites/Terrain/hex_sprites_blend_2.png"), preload("res://Sprites/Terrain/hex_sprites_blend_3.png")]

onready var terrainsprites : Node2D = $TerrainSpritesContainer
onready var tiles : Node2D = $TilesContainer
onready var units : Node2D = $UnitsContainer
onready var effects : Node2D = $EffectsManager

onready var debug : Node = $Debug
onready var network : Node = $Network
onready var game: Node = $Game
onready var ui: Node = $UI

onready var tilemap : TileMap = $TileMap

const __tile_dict : Dictionary = {}

func _ready():
	randomize()
	
	#var sprites : Array = []
	#for x in 12:
	#	for y in 7:
	#		var sprite : Sprite = TerrainGroundSprite.instance()
	#		sprite.position = Vector2(x * 100, y * 100)
	#		sprite.texture = Util.pick_random(TerrainGroundTextures)
	#		sprite.rotation_degrees = (randi() % 4) * 90 + rand_range(-20, 20)
	#		sprites.append(sprite)
	
	#sprites.shuffle()
	#for sprite in sprites:
	#	terrainsprites.add_child(sprite)
	
	for coordinate in tilemap.get_used_cells():
		var tile_index = tilemap.get_cellv(coordinate)
		var tile_instance = HexTile.instance()
		tile_instance.set_position(tilemap.map_to_world(coordinate))
		
		coordinate.x = coordinate.x * 2 + posmod(coordinate.y, 2)
		__tile_dict[coordinate] = tile_instance
		tile_instance.init(self, coordinate, tile_index == 1)
		
		tiles.add_child(tile_instance)
	
	tilemap.queue_free()
	
	MapGenerator.generate_map(self)

func get_tile(coord):
	return __tile_dict.get(coord, null)

# Slow, should only be used during map generation
func get_all_tiles():
	return __tile_dict.values()

func generate_army_id(player_id: int):
	return str(player_id) + "|" + str(network.get_next_id())

remotesync func add_unit(starting_tile_coord: Vector2, starting_power: int, player_id: int) -> Node2D:
	var unit_instance = ArmyUnit.instance()
	units.add_child(unit_instance)
	unit_instance.init(generate_army_id(player_id), self, get_tile(starting_tile_coord), starting_power, game.get_player(player_id))
	return unit_instance
	
remotesync func add_unit_detached(starting_tile_coord: Vector2, starting_power: int, player_id: int) -> Node2D:
	var unit_instance = ArmyUnit.instance()
	units.add_child(unit_instance)
	unit_instance.init_detached(generate_army_id(player_id), self, get_tile(starting_tile_coord), starting_power, game.get_player(player_id))
	return unit_instance

func distance_between(first_tile, second_tile):
	var dx = abs(first_tile.coord.x - second_tile.coord.x)
	var dy = abs(first_tile.coord.y - second_tile.coord.y)
	return dy + max(0, (dx - dy) / 2)

func find_neighbours(center_tile) -> Array:
	var neigbours : Array = []
	
	var center_coordinate : Vector2 = center_tile.coord
	for dir in Util.directions:
		var new_tile = get_tile(center_coordinate + dir)
		if new_tile != null:
			neigbours.append(new_tile)
	
	return neigbours

func find_in_radius(center_tile, radius : int) -> Dictionary:
	var neighbors : Dictionary = {}
	
	var center_coordinate : Vector2 = center_tile.coordinate
	var row_offset : Vector2 = Vector2(-radius, -radius)
	var row_length : int = radius + 1
	while row_offset.y < 0:
		__add_row(neighbors, center_coordinate + row_offset, row_length, 1)
		__add_row(neighbors, center_coordinate - row_offset, row_length, -1)
		row_offset += Vector2(-1, 1)
		row_length += 1
	__add_row(neighbors, center_coordinate + row_offset, radius, 1)
	__add_row(neighbors, center_coordinate - row_offset, radius, -1)
	
	return neighbors

func find_travelable(center_tile, army, distance : int) -> Dictionary:
	var neighbors : Dictionary = {}
	__add_neighbors(neighbors, center_tile, army,  distance)
	neighbors.erase(center_tile)
	return neighbors

func __add_neighbors(tiles : Dictionary, center_tile, army, distance: int):
	if distance == 0:
		return
	
	for dir in Util.directions:
		var new_tile = get_tile(center_tile.coord + dir)
		if new_tile != null and army.can_enter(center_tile, new_tile):
			tiles[new_tile] = true
			if new_tile.army == null or new_tile.army.player == army.player:
				__add_neighbors(tiles, new_tile, army, distance - 1)

func __add_row(tiles : Dictionary, row_start : Vector2, row_length : int, dir : int):
	for i in range(0, row_length):
		var new_tile = get_tile(row_start + Vector2(2*dir*i, 0))
		if new_tile != null:
			tiles[new_tile] = true

#func filter_can_enter(tiles : Dictionary, army):
#	for tile in tiles.keys():
#		if !tile.can_enter(army):
#			tiles.erase(tile)
#
#	return tiles


