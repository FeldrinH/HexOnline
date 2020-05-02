extends Area2D

var base_color = Color(1,1,1)

var manager
var coordinate : Vector2
var blocked : bool

var army = null

func init(manager, coordinate, blocked):
	self.manager = manager
	self.coordinate = coordinate
	self.blocked = blocked

# To be overriden by subclasses. Should return bool indicating if entering_army can enter this tile 
func can_enter(entering_army) -> bool:
	return !blocked

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

func convert_type(type : Script):
	var manager = self.manager
	var coordinate = self.coordinate
	var blocked = self.blocked
	self.set_script(type)
	self.init(manager, coordinate, blocked)
