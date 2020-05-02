extends Node2D

const ArmyUnit = preload("res://ArmyUnit.tscn")
const HexTile = preload("res://HexTile.tscn")
const MapGenerator = preload("res://Scripts/MapGenerator.gd")

onready var army_manager : Node2D = $"../ArmyUnits"
onready var tilemap : TileMap = $"../TileMap"

const __tile_dict = {}

var active = null
var selected = null
var highlighted = {}

var turn_active = false

func _ready():
	for coordinate in tilemap.get_used_cells():
		var tile_instance = HexTile.instance()
		tile_instance.set_position(tilemap.map_to_world(coordinate))
		
		coordinate.x = coordinate.x * 2 + posmod(coordinate.y, 2)
		__tile_dict[coordinate] = tile_instance
		tile_instance.init(self, coordinate, tilemap.get_cellv(coordinate) == 2)
		
		add_child(tile_instance)
	
	tilemap.queue_free()
	
	MapGenerator.generate_map(__tile_dict)

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

func find_neighbors(center_tile, radius : int):
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

func __add_row(tiles, row_start : Vector2, row_length : int, dir : int):
	for i in range(0, row_length):
		var newTile = get_tile(row_start + Vector2(2*dir*i, 0))
		if newTile != null:
			tiles[newTile] = true

func filter_can_enter(tiles : Dictionary, army):
	for tile in tiles.keys():
		if !tile.can_enter(army):
			tiles.erase(tile)
	
	return tiles

func __active_click(event : InputEvent):
	if event.is_action_pressed("ui_mouse_left"):
		if !turn_active:
			if selected == null and active.army != null:
				set_selected(active)
				var neighbors = find_neighbors(active, 2)
				filter_can_enter(neighbors, active.army)
				set_highlighted(neighbors)
			elif selected != null and selected.army != null and highlighted.has(active):
				if active.army == null or active.army.power < active.army.max_power:
					selected.army.move_to(active)
					set_selected(null)
					set_highlighted({})
	elif event.is_action_pressed("ui_mouse_debug"):
		var unit_instance = ArmyUnit.instance()
		army_manager.add_child(unit_instance)
		unit_instance.init(active, 20)

