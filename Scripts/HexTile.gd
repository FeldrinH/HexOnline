extends Area2D

const City = preload("res://City.tscn")
const Capital = preload("res://Capital.tscn")

onready var sprites = $Sprites

var base_color = Color(1,1,1)

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

func add_city() -> Node2D:
	var city_instance = City.instance()
	self.add_child(city_instance)
	city_instance.init(manager)
	return city_instance

func add_capital(side) -> Node2D:
	var city_instance = Capital.instance()
	self.add_child(city_instance)
	self.set_city(city_instance)
	city_instance.init_capital(manager, side)
	return city_instance

func set_city(new_city):
	city = new_city

func can_enter(entering_army) -> bool:
	if blocked:
		return false
	
	if terrain == Util.TERRAIN_WATER:
		return false
	else:
		return true

# When a tile's appearance changes related to ingame logic
func setup_appearance():
	match terrain:
		Util.TERRAIN_GROUND:
			base_color = Color(86/255.0, 125/255.0, 70/255.0)
		Util.TERRAIN_WATER:
			base_color = Color(0, 0, 1)
	update_appearance()

# Updates related to appearance & UI
func update_appearance():
	if manager.selected == self:
		sprites.modulate = Color(0.8,0.8,0)
	elif manager.active == self:
		sprites.modulate = Color(0.6,0,0)
	elif manager.highlighted.has(self):
		sprites.modulate = Color(0,0.8,0)
	else:
		sprites.modulate = base_color
	
	if player != null:
		sprites.modulate += player.unit_color * 0.2

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
	self.player =  new_player
	setup_appearance()
