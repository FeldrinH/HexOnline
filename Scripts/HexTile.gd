extends Area2D

const City = preload("res://City.tscn")
const Capital = preload("res://Capital.tscn")

onready var sprite = $Sprite

var base_color = Color(1,1,1)

var manager
var coordinate : Vector2
var blocked : bool

var terrain : int

var army = null
var city = null

func init(tile_manager, tile_coordinate, tile_blocked):
	manager = tile_manager
	coordinate = tile_coordinate
	blocked = tile_blocked
	
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

func setup_appearance():
	match terrain:
		Util.TERRAIN_GROUND:
			base_color = Color(86/255.0, 125/255.0, 70/255.0)
		Util.TERRAIN_WATER:
			base_color = Color(0, 0, 1)
	sprite.modulate = base_color

func update_appearance():
	if manager.selected == self:
		sprite.modulate = Color(0.8,0.8,0)
	elif manager.active == self:
		sprite.modulate = Color(0.6,0,0)
	elif manager.highlighted.has(self):
		sprite.modulate = Color(0,0.8,0)
	else:
		sprite.modulate = base_color

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
