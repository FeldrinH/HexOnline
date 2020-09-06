extends "Main.gd"

func _ready():
	world.generate_map()
	
	Network.create_server()
	Network.connect("client_connecting", self, "__on_client_connecting")
	
	add_ui(world_ui)

func __on_client_connecting(id: int):
	world.send_map(id)
	world.game.send_state(id)
