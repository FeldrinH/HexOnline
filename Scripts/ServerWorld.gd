extends "World.gd"

func _ready():
	network.create_server(SceneManager.get_shared("profile"))
	
	ui.show("Lobby")
	ui.show("HUD")
	
	yield(generate_map(), "completed")
	
	ui.show("Overlay")
	ui.show("DebugMenu")
	
	game.start_game()
