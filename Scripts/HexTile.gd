extends Area2D

const City = preload("res://City.tscn")
const Capital = preload("res://Capital.tscn")
const ground_tiles = [preload("res://Sprites/land_tile_4.png"), preload("res://Sprites/land_tile_9.png"), preload("res://Sprites/land_tile_10.png"), preload("res://Sprites/land_tile_11.png"), preload("res://Sprites/land_tile_12.png")]
const sea_tiles = [preload("res://Sprites/sea_tile_1.png"), preload("res://Sprites/sea_tile_2.png"), preload("res://Sprites/sea_tile_3.png")]
const base_tile = preload("res://Sprites/tile.png")
const wasteland_tile = preload("res://Sprites/wasteland_tile_1.png")

onready var sprites : Node2D = $Sprites
onready var border : Node2D = $Border
onready var shore : Node2D = $Shore
onready var border_sections : Array = border.get_children()
onready var shore_sections : Array = shore.get_children()

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
	remove_city()
	city = City.instance()
	self.add_child(city)
	city.init_name(world, name)
	return city

puppet func add_capital(player_id: int) -> Node2D:
	remove_city()
	city = Capital.instance()
	self.add_child(city)
	city.init_capital(world, world.game.get_player(player_id))
	return city

func remove_city():
	if city:
		city.free()
	city = null

func try_occupy(new_player: Node):	
	if army and army.player != new_player: # Can't occupy if tile has opposing army
		return
	
	if city and city.is_capital and !city.conquered and city.player != new_player: # Extra checks if occupying capital
		if !(army and army.player == new_player): # Can't occupy capital if your army is not on tile
			return
		city.conquer(new_player)
	
	set_player(new_player)

# When a tile's appearance changes related to ingame logic
puppet func setup_appearance():
	match terrain:
		Util.TERRAIN_GROUND:
			$Sprites.texture = Util.pick_random(ground_tiles)
		Util.TERRAIN_WATER:
			$Sprites.texture = Util.pick_random(sea_tiles)
	show_highlight(false)
	create_shoreline()

# Updates related to appearance & UI
func show_highlight(is_highlighted):
	if is_highlighted:
		sprites.modulate = base_color.blend(Color(0, 1, 0, 0.7))
		shore.modulate = base_color.blend(Color(0, 1, 0, 0.5))
	else:
		sprites.modulate = base_color
		shore.modulate = base_color

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

func find_neighbours():
	return world.find_neighbours(self)

func __mouse_entered():
	world.ui.set_hovered(self)

func __mouse_exited():
	if world.ui.hovered == self:
		world.ui.set_hovered(null)

func _input_event(viewport, event, shape_idx):
	if world.ui.hovered == self:
		world.ui.hovered_click(event)

puppet func set_terrain(new_terrain : int):
	terrain = new_terrain

func set_player(new_player: Node):
	player = new_player
	update_border_appearance()
	for adjacent_tile in world.find_neighbours(self):
		adjacent_tile.update_border_appearance()

puppet func set_player_id(new_player_id : int):
	set_player(world.game.get_player(new_player_id))
