extends Area2D

onready var manager = $".."

var coordinate : Vector2

var army = null

func mouse_entered():
	manager.set_active(self)

func mouse_exited():
	if manager.active == self:
		manager.set_active(null)

func update_appearance():
	if manager.selected == self:
		modulate = Color(2,2,0)
	elif manager.active == self:
		modulate = Color(2,0,0)
	else:
		modulate = Color(1,1,1)

func input_event(viewport, event, shape_idx):
	if manager.active == self:
		manager.active_click(event)
