extends Area2D

var base_color = Color(1,1,1)

var manager
var coordinate : Vector2
var blocked : bool

var terrain = Util.TERRAIN_GROUND

var army = null

func init(manager, coordinate, blocked):
	self.manager = manager
	self.coordinate = coordinate
	self.blocked = blocked
	
	$Label.text = str(coordinate)

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
			base_color = Color(1.2,1,1)
		Util.TERRAIN_WATER:
			base_color = Color(0,0,2)
	modulate = base_color

func update_appearance():
	if manager.selected == self:
		modulate = Color(2,2,0)
	elif manager.active == self:
		modulate = Color(2,0,0)
	elif manager.highlighted.has(self):
		modulate = Color(0,2,0)
	else:
		modulate = base_color

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
