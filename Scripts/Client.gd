extends Node

var player: Node

var id: int
var display_name: String

func init(client_id: int, client_display_name: String):
	id = client_id
	display_name = client_display_name
	set_name(str(id))
	set_network_master(id)

puppetsync func update_profile(new_display_name: String):
	display_name = new_display_name

puppetsync func select_player(new_player: Node):
	if player:
		player.client = null
	if new_player:
		new_player.client = self
	player = new_player
