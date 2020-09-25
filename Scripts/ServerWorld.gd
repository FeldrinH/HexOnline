extends "World.gd"

func _ready():
	network.create_server(SceneManager.get_shared("profile"))
	
	ui.show("Lobby")
	ui.show("HUD")
