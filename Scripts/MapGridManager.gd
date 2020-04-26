extends Node2D

const army_unit = preload("res://ArmyUnit.tscn")
const tile_scene = preload("res://HexTile.tscn")

onready var army_manager = $"../ArmyUnits"
onready var tilemap : TileMap = $"../TileMap"

const tile_dict = {}
var active = null
var selected = null

var highlighted = {}

const moveDirections = [
	Vector2(2, 0), Vector2(1, 1),
	Vector2(-1, 1), Vector2(-2, 0),
	Vector2(-1, -1), Vector2(1, -1)
]

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
	
		
func highlight_tiles(tiles):
	var previous_highlighted = highlighted
	highlighted = tiles
	
	for tile in previous_highlighted:
		tile.update_appearance()
		
	for tile in tiles:
		tile.update_appearance()

func get_tile(coord):
	return tile_dict.get(coord, null)

func find_neighbors(current_tile):
	var neighbors = {}
	for i in moveDirections:
		var newTile = get_tile(current_tile.coordinate + i)
		if newTile != null:
			neighbors[newTile] = 0
	return neighbors

func active_click(event : InputEvent):
	if event.is_action_pressed("ui_mouse_left"):
		if selected == null and active.army != null:
			set_selected(active)
			highlight_tiles(find_neighbors(active))
		elif selected != null and selected.army != null:
			selected.army.move_to(active)
			set_selected(null)
			highlight_tiles({})
	elif event.is_action_pressed("ui_mouse_debug"):
		var unit_instance = army_unit.instance()
		army_manager.add_child(unit_instance)
		unit_instance.init(active, 50)

