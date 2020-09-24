extends "World.gd"

func _ready():
	generate_map()
	
	network.create_server(SceneManager.get_shared("profile"))
	
	ui.show("Lobby")
	
	ui.show("HUD")
	ui.show("Overlay")
	ui.show("DebugMenu")
	
	game.start_game()
