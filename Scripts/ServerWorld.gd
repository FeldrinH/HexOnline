extends "World.gd"

func _ready():
	generate_map()
	
	network.create_server(SceneManager.get_shared("profile", { "display_name": OS.get_environment("USERNAME") }))
	
	ui.show("HUD")
	ui.show("Overlay")
	ui.show("DebugMenu")
	
	game.start_game()
