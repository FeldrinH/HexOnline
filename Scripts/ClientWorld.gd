extends "World.gd"

func _ready():
	network.join_server(SceneManager.get_shared("ip", "localhost"), SceneManager.get_shared("profile", { "display_name": OS.get_environment("USERNAME") }))
	
	ui.show("HUD")
	ui.show("Overlay")
	ui.show("DebugMenu")
	
