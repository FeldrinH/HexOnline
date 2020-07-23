extends Node

const PORT = 2000
const MAX_PLAYERS = 4

const Client = preload("res://Client.tscn")

onready var world: Node2D = $".."

var clients: Dictionary = {}
var our_client: Node = null
var is_server: bool = false

func create_server(client_display_name: String):
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(PORT, MAX_PLAYERS)
	get_tree().network_peer = peer
	is_server = true
	get_tree().connect("network_peer_connected", self, "__server_peer_connected")
	
	print("Server created")
	
	# Initialize server's client
	__client_connected_to_server(client_display_name)

func join_server(ip: String, client_display_name: String):
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, PORT)
	get_tree().network_peer = peer
	is_server = false
	get_tree().connect("connected_to_server", self, "__client_connected_to_server", [client_display_name])
	
	print("Connecting...")

# Run on server when new client connects
func __server_peer_connected(id: int):
	# Send existing clients to new client
	for client in clients.values():
		rpc_id(id, "add_client", client.id, client.display_name)
	
	print("Peer connected: " + str(id))

# Run on client when connected to server
func __client_connected_to_server(client_display_name: String):
	var id = get_tree().get_network_unique_id()
	our_client = add_client(id, client_display_name)
	rpc("request_add_client", id, client_display_name)
	
	print("Connected to server: " + str(id))

master func request_add_client(id: int, display_name: String):
	if get_tree().get_rpc_sender_id() == id:
		rpc("add_client", id, display_name)
		print("Joined: " + display_name)

puppetsync func add_client(id: int, display_name: String) -> Node:
	if clients.has(id):
		return clients[id] # Client exists
	
	var client = Client.instance()
	client.init(id, display_name)
	add_child(client)
	clients[id] = client
	
	return client
