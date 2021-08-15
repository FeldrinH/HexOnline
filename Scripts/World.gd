extends Node2D

const ArmyUnit = preload("res://ArmyUnit.tscn")
const HexTile = preload("res://HexTile.tscn")
const MapGenerator = preload("res://Scripts/MapGenerator.gd")
const MapSender = preload("res://Scripts/MapSender.gd")

#const TerrainGroundTextures = [preload("res://Sprites/Terrain/hex_sprites_blend_1.png"), preload("res://Sprites/Terrain/hex_sprites_blend_2.png"), preload("res://Sprites/Terrain/hex_sprites_blend_3.png")]

onready var forestsprites : Node2D = $ForestSpritesContainer
onready var tiles : Node2D = $TilesContainer
onready var units : Node2D = $UnitsContainer
onready var effects : Node2D = $EffectsManager
onready var tilemap : TileMap = $TileMap

onready var network: Node = $Network
onready var game: Node = $Game
onready var ui: Node = $UI

const __tile_dict : Dictionary = {}
const __tile_array : Array = []

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
	
	for coord in tilemap.get_used_cells():
		var tile_index = tilemap.get_cellv(coord)
		var tile_instance = HexTile.instance()
		var hex_coord = Vector2(coord.x * 2 + posmod(coord.y, 2), coord.y)
		
		__tile_dict[hex_coord] = tile_instance
		__tile_array.append(tile_instance)
		tile_instance.init(self, hex_coord, tilemap.map_to_world(coord), tile_index == 1, len(__tile_array)-1)
		tile_instance.set_name(str(hex_coord))
		
		tiles.add_child(tile_instance)
	
	tilemap.queue_free()
	
	setup_tiles_appearance()

func generate_map():
	var mapgen_coroutine = MapGenerator.generate_map(self)
	while mapgen_coroutine is GDScriptFunctionState and mapgen_coroutine.is_valid():
		setup_tiles_appearance()
		yield(get_tree(), "idle_frame")
		mapgen_coroutine = mapgen_coroutine.resume()

func send_map(target_id: int):
	MapSender.send_map(self, target_id)

func clear_map():
	for tile in get_all_tiles():
		if tile.city:
			tile.remove_city()
		tile.army = null
	
	for unit in units.get_children():
		unit.free()

func get_tile(coord):
	return __tile_dict.get(coord, null)
	
func get_tile_by_id(id):
	return __tile_array[id]

func get_all_tiles():
	return __tile_array

puppet func setup_tiles_appearance():
	for tile in __tile_array:
		tile.setup_appearance()

func get_capital_tiles():
	var capital_tiles = []
	var tiles = get_all_tiles()
	for tile in tiles:
		if tile.city and tile.city.is_capital:
			capital_tiles.append(tile)
	return capital_tiles

func generate_army_id(player_id: int):
	return str(player_id) + "|" + str(network.get_next_id())

puppetsync func add_unit(starting_tile_coord: Vector2, starting_power: int, player_id: int, silent: bool, name_override: String = "") -> Node2D:
	var unit_instance = ArmyUnit.instance()
	units.add_child(unit_instance)
	unit_instance.init(self, get_tile(starting_tile_coord), starting_power, game.get_player(player_id), silent)
	unit_instance.set_name(generate_army_id(player_id) if name_override == "" else name_override)
	return unit_instance
	
func add_unit_detached(starting_tile_coord: Vector2, starting_power: int, player_id: int, silent: bool, name_override: String = "") -> Node2D:
	var unit_instance = ArmyUnit.instance()
	units.add_child(unit_instance)
	unit_instance.init_detached(self, get_tile(starting_tile_coord), starting_power, game.get_player(player_id), silent)
	unit_instance.set_name(generate_army_id(player_id) if name_override == "" else name_override)
	return unit_instance

func distance_between(first_tile, second_tile):
	return Util.distance_between(first_tile.coord, second_tile.coord)

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

func find_travelable(center_tile, player, distance : int) -> Dictionary:
	var neighbors : Dictionary = {}
	__add_neighbors(neighbors, center_tile, player, distance, true)
	neighbors.erase(center_tile)
	return neighbors

func __add_neighbors(tiles : Dictionary, center_tile, player, distance: int, is_first: bool):
	if distance <= 0:
		return
	
	for dir in Util.directions:
		var new_tile = get_tile(center_tile.coord + dir)
		if new_tile and __can_enter(center_tile, new_tile, is_first):
			tiles[new_tile] = true
			if (new_tile.army == null or new_tile.army.player == player) and center_tile.terrain == new_tile.terrain:
				__add_neighbors(tiles, new_tile, player, distance - 1, false)

func __add_row(tiles : Dictionary, row_start : Vector2, row_length : int, dir : int):
	for i in range(0, row_length):
		var new_tile = get_tile(row_start + Vector2(2*dir*i, 0))
		if new_tile != null:
			tiles[new_tile] = true

static func __can_enter(leave_tile, enter_tile, is_first: bool) -> bool:
	if enter_tile.blocked:
		return false
	
	if enter_tile.terrain == leave_tile.terrain:
		return true
	else:
		return is_first and (enter_tile.city and enter_tile.city.is_port or leave_tile.city and leave_tile.city.is_port)

func get_all_units():
	return units.get_children()

func get_player_units(player) -> Array:
	var player_units := []
	for i in units.get_children():
		if i.player == player:
			player_units.append(i)
	return player_units

#func filter_can_enter(tiles : Dictionary, army):
#	for tile in tiles.keys():
#		if !tile.can_enter(army):
#			tiles.erase(tile)
#
#	return tiles


