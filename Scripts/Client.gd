extends Node

signal player_changed(new_player)

var world: Node

var id: int
var profile: Dictionary
var player: Node

func init(client_world: Node, client_id: int, client_profile: Dictionary, client_player_id: int):
	world = client_world
	id = client_id
	profile = client_profile
	set_player_id(client_player_id)
	set_name(str(id))

func cleanup():
	set_player_id(-1)

func __set_player(new_player: Node):
	player = new_player
	emit_signal("player_changed", player)

puppetsync func set_player_id(new_player_id: int):
	var new_player = world.game.get_player(new_player_id)
	
	if player:
		player.__set_client(null)
	if new_player:
		if new_player.client:
			new_player.client.__set_player(null)
		new_player.__set_client(self)
	__set_player(new_player)

master func select_player(new_player_id: int):
	if get_tree().get_rpc_sender_id() == id:
		if !world.game.get_player(new_player_id) or !world.game.get_player(new_player_id).client:
			rpc("set_player_id", new_player_id)
