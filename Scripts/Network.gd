extends Node

signal client_connecting(id, client) # Emitted on server when client is connecting, so initial data can be sent from other nodes
signal client_connected(id, client) # Emitted on all sides after a new client has connected
signal our_client_connected() # Emitted on client after all server-side initial data has been sent

const Client = preload("res://Client.tscn")

const PORT = 2000
const MAX_CLIENTS = 8

onready var world: Node = $".."

var our_client: Node # Exists on client_connecting
var is_connected: bool = false # True on our_client_connected
var is_server: bool = false
var clients: Dictionary = {}

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var __next_id: int = 0

# Networking utility functions for use during game
func get_next_id() -> int:
	__next_id += 1
	return __next_id

func get_client(id: int) -> Node:
	if clients.has(id):
		return clients[id]
	else:
		return null

func get_our_player() -> Node:
	return our_client.player

func get_rpc_sender_player() -> Node:
	return get_client(get_tree().get_rpc_sender_id()).player

# Networking RPC functions
# Run on server when new client announces itself
master func register_client(profile: Dictionary):
	var id = get_tree().get_rpc_sender_id()
	if !clients.has(id):
		rpc("add_remote_client", id, profile)
		
		for client in clients.values():
			rpc_id(id, "add_remote_client", client.id, client.profile, client.player.id if client.player else -1)
		
		emit_signal("client_connecting", id, get_client(id))
		
		rpc_id(id, "set_synced_values", rng.seed, __next_id)
		rpc_id(id, "our_client_connected")
		
		print("Client connected: " + profile.display_name)

puppetsync func add_remote_client(id: int, profile: Dictionary, player_id: int):
	if !clients.has(id):
		var new_client = Client.instance()
		new_client.init(world, id, profile, player_id)
		add_child(new_client)
		clients[id] = new_client
		
		emit_signal("client_connected", id, new_client)

puppetsync func set_synced_values(rng_seed: int, next_id: int):
	rng.set_seed(rng_seed)
	__next_id = next_id

puppetsync func our_client_connected():
	is_connected = true
	emit_signal("our_client_connected")
	print("Our client connected: " + str(our_client.id))

# Server lifecycle functions
func cleanup_connections():
	if get_tree().network_peer:
		get_tree().network_peer = null
	get_tree().disconnect("connected_to_server", self, "__client_connected_to_server")

func create_server(our_profile: Dictionary):
	cleanup_connections()
	
	rng.randomize()
	
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(PORT, MAX_CLIENTS)
	get_tree().network_peer = peer
	is_server = true
	
	print("Server created")
	
	# Initialize server's client
	__client_connected_to_server(our_profile)

func join_server(ip: String, our_profile: Dictionary):
	cleanup_connections()
	
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, PORT)
	get_tree().network_peer = peer
	is_server = false
	get_tree().connect("connected_to_server", self, "__client_connected_to_server", [our_profile])
	
	print("Client created")

# Run on client when connected to server
func __client_connected_to_server(our_profile: Dictionary):
	rpc("register_client", our_profile)
