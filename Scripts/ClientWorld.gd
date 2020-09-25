extends "World.gd"

func _ready():
	network.join_server(SceneManager.get_shared("ip"), SceneManager.get_shared("profile"))
	network.connect("client_initialized", self, "__on_client_initialized")

func __on_client_initialized():
	ui.show("Lobby")
	ui.show("HUD")
