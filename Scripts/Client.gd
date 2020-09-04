extends Node

var world: Node

var id: int
var display_name: String
var player: Node

func init(client_world: Node, client_id: int, client_display_name: String, player: Node):
	world = client_world
	id = client_id
	display_name = client_display_name
	set_player(player)
	set_name(str(id))
	set_network_master(id)

func set_player(new_player: Node):
	if player:
		player.client = null
	if new_player:
		new_player.client = self
	player = new_player

puppetsync func set_player_id(new_player_id: int):
	set_player(world.game.get_player(new_player_id))
