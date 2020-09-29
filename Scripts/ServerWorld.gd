extends "World.gd"

func _ready():
	network.create_server(SettingsManager.get_shared("profile"))
	
	ui.show("Lobby")
	ui.show("HUD")
