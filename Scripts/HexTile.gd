extends Area2D

var coordinate : Vector2

func mouse_entered():
	self.modulate = Color(255, 0, 0)


func mouse_exited():
	self.modulate = Color(255, 255, 255)

func mouse_pressed(Node, event, shape):
	if event is InputEventMouseButton && event.pressed:
		print(coordinate)
