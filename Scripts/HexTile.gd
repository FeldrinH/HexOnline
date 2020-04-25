extends Area2D

onready var tile_manager = $".."

var coordinate : Vector2
var active : bool = false

func mouse_entered():
	set_active(true)

func mouse_exited():
	set_active(false)

func set_active(new_active):
	if new_active:
		if tile_manager.active_tile != null:
			tile_manager.active_tile.set_active(false)
		
		tile_manager.active_tile = self
		
		self.modulate = Color(255,0,0)
	else:
		if tile_manager.active_tile == self:
			tile_manager.active_tile = null
		
		self.modulate = Color(255,255,255)
	
	active = new_active

func mouse_pressed(Node, event : InputEvent, shape):
	if event.is_action_pressed("ui_mouse_left"):
		print(coordinate)
