extends Node

onready var world: Node = $World

var lobby_ui: Node
var world_ui: Node

func _enter_tree():
	lobby_ui = remove_ui($LobbyUI)
	world_ui = remove_ui($WorldUI)

func add_ui(ui_root: Node):
	add_child(ui_root)
	ui_root.init(world)

func remove_ui(ui_root: Node) -> Node:
	remove_child(ui_root)
	return ui_root
