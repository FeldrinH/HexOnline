extends Area2D

const City = preload("res://City.tscn")
const Capital = preload("res://Capital.tscn")
const ground_tiles = [preload("res://Sprites/land_tile_4.png"), preload("res://Sprites/land_tile_9.png"), preload("res://Sprites/land_tile_10.png"), preload("res://Sprites/land_tile_11.png"), preload("res://Sprites/land_tile_12.png")]
const sea_tiles = [preload("res://Sprites/sea_tile_1.png"), preload("res://Sprites/sea_tile_2.png"), preload("res://Sprites/sea_tile_3.png")]
const base_tile = preload("res://Sprites/tile.png")

onready var sprites : Node2D = $Sprites
onready var border : Node2D = $Border
onready var border_sections : Array = [$"Border/1", $"Border/2", $"Border/3", $"Border/4", $"Border/5", $"Border/6"]
onready var shore_sections : Array = [$"Shore/1", $"Shore/2", $"Shore/3", $"Shore/4", $"Shore/5", $"Shore/6"]

var base_color : Color = Color(1,1,1)

var world: Node
var coord: Vector2
var blocked: bool
var terrain: int

var player: Node = null
var army: Node2D = null
var city: Node2D = null

func init(tile_world, tile_coord, tile_position, tile_blocked):
	world = tile_world
	coord = tile_coord
	position = tile_position
	blocked = tile_blocked
	#world.connect("unit_enter", self, "__unit_enter")
	$Label.text = str(coord)

puppet func add_city(name: String) -> Node2D:
	city = City.instance()
	self.add_child(city)
	city.init_name(world, name)
	return city

puppet func add_capital(player_id: int) -> Node2D:
	city = Capital.instance()
	self.add_child(city)
	city.init_capital(world, world.game.get_player(player_id))
	return city

# When a tile's appearance changes related to ingame logic
puppet func setup_appearance():
	match terrain:
		Util.TERRAIN_GROUND:
			$Sprites.texture = Util.pick_random(ground_tiles)
			base_color = Color(1, 1, 1, 1) #Color(86/255.0, 125/255.0, 70/255.0, 0)
		Util.TERRAIN_WATER:
			$Sprites.texture = Util.pick_random(sea_tiles)
			base_color = Color(1, 1, 1, 1)
	update_highlight_appearance()
	create_shoreline()

# Updates related to appearance & UI
func update_highlight_appearance():
	if world.ui.selected == self:
		sprites.modulate = Color(0.8,0.8,0)
	elif world.ui.hovered == self:
		sprites.modulate = Color(0.6,0,0)
	elif world.ui.highlighted.has(self):
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
			var adjacent_tile = world.get_tile(coord + Util.directions[i])
			if adjacent_tile != null and adjacent_tile.player == player:
				border_sections[i].visible = false
			else:
				border_sections[i].visible = true
	else:
		border.visible = false

func create_shoreline():
	for i in range(0,6):
			var adjacent_tile = world.get_tile(coord + Util.directions[i])
			if adjacent_tile != null and adjacent_tile.terrain ==  Util.TERRAIN_WATER and self.terrain == Util.TERRAIN_GROUND:
				shore_sections[i-1].visible = true
			else:
				shore_sections[i-1].visible = false

func __mouse_entered():
	world.ui.set_hovered(self)

func __mouse_exited():
	if world.ui.hovered == self:
		world.ui.set_hovered(null)

func __input_event(viewport, event, shape_idx):
	if world.ui.hovered == self:
		world.ui.__hovered_click(event)

puppet func set_terrain(new_terrain : int):
	terrain = new_terrain

puppet func set_player(new_player_id : int):
	player = world.game.get_player(new_player_id)
	update_border_appearance()
	for adjacent_tile in world.find_neighbours(self):
		adjacent_tile.update_border_appearance()
