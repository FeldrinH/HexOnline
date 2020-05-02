extends "BaseTile.gd"

func setup():
	base_color = Color(0,0,2)
	update_appearance()

func can_enter(entering_army) -> bool:
	if blocked:
		return false
	
	return false
