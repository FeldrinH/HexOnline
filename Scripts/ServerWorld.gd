extends "World.gd"

func _ready():
	generate_map()
	
	network.create_server({ "display_name": OS.get_environment("USERNAME") })
	
	ui.show("HUD")
	ui.show("Overlay")
	ui.show("DebugMenu")
	
	game.start_game()
