extends "World.gd"

func _ready():
	network.join_server(SceneManager.get_shared("ip", "88.196.236.78"), SceneManager.get_shared("profile", { "display_name": OS.get_environment("USERNAME") }))
	network.connect("client_initialized", self, "__on_client_initialized")

func __on_client_initialized():
	ui.show("HUD")
	ui.show("Overlay")
	ui.show("DebugMenu")
