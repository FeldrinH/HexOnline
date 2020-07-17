extends Node

const PORT = 2000
const MAX_PLAYERS = 2

var players = {}
var peer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if Input.is_action_just_pressed("ui_right"):
		create_server()
		print("created")
	if Input.is_action_just_pressed("ui_left"):
		join_server()
		
func create_server():
	peer =  NetworkedMultiplayerENet.new()
	peer.create_server(PORT, MAX_PLAYERS)
	print("Server created")
	
func join_server():
	peer.create_client("localhost", PORT)
	print("client connected")

