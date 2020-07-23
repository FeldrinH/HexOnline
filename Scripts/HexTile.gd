extends Area2D

const City = preload("res://City.tscn")
const Capital = preload("res://Capital.tscn")
const ground_tiles = [preload("res://Sprites/land_tile_1.png"), preload("res://Sprites/land_tile_2.png"), preload("res://Sprites/land_tile_3.png"), preload("res://Sprites/land_tile_4.png"), preload("res://Sprites/land_tile_5.png"), preload("res://Sprites/land_tile_6.png"), preload("res://Sprites/land_tile_7.png"), preload("res://Sprites/land_tile_8.png"), preload("res://Sprites/land_tile_9.png")]
const base_tile = preload("res://Sprites/tile.png")

onready var sprites : Node2D = $Sprites
onready var border : Node2D = $Border
onready var border_sections : Array = [$"Border/1", $"Border/2", $"Border/3", $"Border/4", $"Border/5", $"Border/6"]

var base_color : Color = Color(1,1,1)

var manager
var coordinate : Vector2
var blocked : bool
var terrain : int

var player = null
var army = null
var city = null

func init(tile_manager, tile_coordinate, tile_blocked):
	manager = tile_manager
	coordinate = tile_coordinate
	blocked = tile_blocked
	manager.connect("unit_enter", self, "__unit_enter")
	$Label.text = str(coordinate)

func add_city(name) -> Node2D:
	city = City.instance()
	self.add_child(city)
	city.init_name(manager, name)
	return city

func add_capital(side) -> Node2D:
	city = Capital.instance()
	self.add_child(city)
	self.set_city(city)
	city.init_capital(manager, side)
	return city

func set_city(new_city):
	city = new_city

# When a tile's appearance changes related to ingame logic
func setup_appearance():
	match terrain:
		Util.TERRAIN_GROUND:
			$Sprites.texture = Util.pick_random(ground_tiles)
			base_color = Color(1, 1, 1, 1) #Color(86/255.0, 125/255.0, 70/255.0, 0)
		Util.TERRAIN_WATER:
			$Sprites.texture = base_tile
			base_color = Color(0, 0, 1)
	update_highlight_appearance()

# Updates related to appearance & UI
func update_highlight_appearance():
	if manager.selected == self:
		sprites.modulate = Color(0.8,0.8,0)
	elif manager.active == self:
		sprites.modulate = Color(0.6,0,0)
	elif manager.highlighted.has(self):
		sprites.modulate = base_color.blend(Color(0, 1, 0, 0.7))
	else:
		sprites.modulate = base_color
	
#	if player != null:
#		sprites.modulate += player.unit_color * 0.2

func update_border_appearance():
	if player != null:
		border.visible = true
		border.modulate = player.unit_color
		
		for i in range(0,6):
			var adjacent_tile = manager.get_tile(coordinate + Util.directions[i])
			if adjacent_tile != null and adjacent_tile.player == player:
				border_sections[i].visible = false
			else:
				border_sections[i].visible = true
	else:
		border.visible = false

func __mouse_entered():
	manager.set_active(self)

func __mouse_exited():
	if manager.active == self:
		manager.set_active(null)

func __input_event(viewport, event, shape_idx):
	if manager.active == self:
		manager.__active_click(event)

func set_terrain(new_terrain : int):
	terrain = new_terrain
	setup_appearance()

func set_player(new_player):
	player = new_player
	update_border_appearance()
	for adjacent_tile in manager.find_neighbours(self):
		adjacent_tile.update_border_appearance()
