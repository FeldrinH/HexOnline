extends Node

signal client_changed(new_client)

export var unit_color : Color

var world : Node2D

var id: int = -1
var client: Node
var capital: Node2D
var selectable: bool = true
# var has_lost: bool = false

func init(player_world, player_id):
	world = player_world
	id = player_id

func set_capital(new_capital):
	capital = new_capital

func __set_client(new_client):
	client = new_client
	emit_signal("client_changed", client)

func is_inactive() -> bool:
	return capital.conquered or !client
