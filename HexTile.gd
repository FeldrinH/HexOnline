extends Area2D

func mouse_entered():
	self.modulate = Color(255, 0, 0)


func mouse_exited():
	self.modulate = Color(255, 255, 255)
