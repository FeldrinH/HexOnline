extends Node2D

signal turn_start(starting_player)
signal turn_end(ending_player)
signal unit_enter(unit)

const ArmyUnit = preload("res://ArmyUnit.tscn")
const HexTile = preload("res://HexTile.tscn")
const MapGenerator = preload("res://Scripts/MapGenerator.gd")

onready var tiles : Node2D = $TilesContainer
onready var units : Node2D = $UnitsContainer
onready var effects : Node2D = $EffectsManager

onready var tilemap : TileMap = $TileMap

const __tile_dict : Dictionary = {}

onready var players : Array = $Players.get_children()
onready var current_player : Node = players[0]

var active = null
var selected = null
var highlighted = {}

var turn_active = false

func _ready():
	for player in players:
		player.init_manager(self)
	
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

func create_players():
	pass

func set_active(new_active):
	var previous_active = active
	active = new_active
	if new_active != null:
		new_active.update_appearance()
	if previous_active != null:
		previous_active.update_appearance()

func set_selected(new_selected):
	var previous_selected = selected
	selected = new_selected
	if new_selected != null:
		new_selected.update_appearance()
	if previous_selected != null:
		previous_selected.update_appearance()

func set_highlighted(tiles : Dictionary):
	var previous_highlighted = highlighted
	highlighted = tiles
	
	for tile in previous_highlighted:
		tile.update_appearance()
		
	for tile in tiles:
		tile.update_appearance()

func get_tile(coord):
	return __tile_dict.get(coord, null)

# Slow, should only be used during map generation
func get_all_tiles():
	return __tile_dict.values()

func add_unit(starting_tile : Node2D, starting_power : int, side : Node) -> Node2D:
	var unit_instance = ArmyUnit.instance()
	units.add_child(unit_instance)
	unit_instance.init(self, starting_tile, starting_power, side)
	return unit_instance
	
func add_unit_detached(starting_tile : Node2D, starting_power : int, side : Node) -> Node2D:
	var unit_instance = ArmyUnit.instance()
	units.add_child(unit_instance)
	unit_instance.init_detached(self, starting_tile, starting_power, side)
	return unit_instance

func find_in_radius(center_tile, radius : int):
	var neighbors = {}
	
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

func find_travelable(center_tile, army, distance : int):
	var neighbors = {}
	__add_neighbors(neighbors, center_tile.coordinate, army,  distance)
	neighbors.erase(center_tile)
	return neighbors

func __add_neighbors(tiles, center : Vector2, army, distance: int):
	if distance == 0:
		return
	
	for dir in Util.directions:
		var new_tile = get_tile(center + dir)
		if new_tile != null and new_tile.can_enter(army):
			tiles[new_tile] = true
			if new_tile.army == null or new_tile.army.player == army.player:
				__add_neighbors(tiles, new_tile.coordinate, army, distance - 1)

func __add_row(tiles, row_start : Vector2, row_length : int, dir : int):
	for i in range(0, row_length):
		var new_tile = get_tile(row_start + Vector2(2*dir*i, 0))
		if new_tile != null:
			tiles[new_tile] = true

func filter_can_enter(tiles : Dictionary, army):
	for tile in tiles.keys():
		if !tile.can_enter(army):
			tiles.erase(tile)
	
	return tiles

func __active_click(event : InputEvent):
	if event.is_action_pressed("ui_mouse_left"):
		if !turn_active:
			if selected == null:
				if active.army != null and active.army.player == current_player:
					set_selected(active)
					var neighbors = find_travelable(active, active.army, 2)
					#filter_can_enter(neighbors, active.army)
					set_highlighted(neighbors)
			else: # selected != null
				if highlighted.has(active):
					if selected.army != null:
						selected.army.move_to(active)
						set_selected(null)
						set_highlighted({})
				else: # !highlighted.has(active):
					set_selected(null)
					set_highlighted({})
	elif event.is_action_pressed("ui_mouse_debug"):
		add_unit(active, 20, current_player)

func _unhandled_key_input(event):
	if event.is_action_pressed("change_side"):
		current_player = players[(players.find(current_player) + 1) % players.size()]
		set_selected(null)
		set_highlighted({})
		print("changed side. Current side : " + str(current_player.id))
