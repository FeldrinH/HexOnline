extends Node

onready var world: Node2D = $".."
var overlay: Node
var hud: CanvasLayer
var debug: CanvasLayer

func _enter_tree():
	overlay = remove_ui($Overlay)
	hud = remove_ui($HUD)
	debug = remove_ui($DebugMenu)

func _ready():
	world.network.connect("connection_finalized", self, "__on_connected_to_server")

func add_ui(ui_root: Node):
	add_child(ui_root)
	ui_root.init(world)

func remove_ui(ui_root: Node) -> Node:
	remove_child(ui_root)
	return ui_root

func __on_connected_to_server():
	add_ui(overlay)
	add_ui(hud)
	add_ui(debug)
