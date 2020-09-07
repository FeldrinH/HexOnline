extends Node

signal client_connecting(id) # Emitted on server when client is connecting, so initial data can be sent from other nodes
signal client_connected(id, profile) # Emitted on all sides after a new client has connected
signal our_client_connected() # Emitted on client after all server-side initial data has been sent

const PORT = 2000
const MAX_PLAYERS = 4

var clients: Dictionary = {}
var is_server: bool = false

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var __next_id: int = 0

var our_id: int = -1
var our_profile: Dictionary = { "display_name": OS.get_environment("USERNAME") }

# Networking utility functions for use during game
func get_next_id() -> int:
	__next_id += 1
	return __next_id

func get_profile(id: int) -> Node:
	if clients.has(id):
		return clients[id]
	else:
		return null

#func get_our_id() -> int:
#	return our_id

func get_rpc_sender_id() -> int:
	return get_tree().get_rpc_sender_id()

# Networking RPC functions
func add_client(id: int, profile: Dictionary):
	clients[id] = profile

puppetsync func add_remote_client(id: int, profile: Dictionary):
	if !clients.has(id):
		add_client(id, profile)
	
	emit_signal("client_connected", id, profile)

# Run on server when new client announces itself
master func request_register_client(profile: Dictionary):
	var id = get_rpc_sender_id()
	rpc("add_remote_client", id, profile)
	
	for client_id in clients:
		rpc_id(id, "add_remote_client", client_id, clients[client_id])
	
	emit_signal("client_connecting", id)
	
	rpc_id(id, "set_synced_values", rng.seed, __next_id)
	rpc_id(id, "our_client_connected")
	
	print("Client connected: " + profile.display_name)

puppetsync func set_synced_values(rng_seed: int, next_id: int):
	rng.set_seed(rng_seed)
	__next_id = next_id

puppetsync func our_client_connected():
	emit_signal("our_client_connected")
	print("Our client connected: " + str(our_id))

# Server lifecycle functions
func cleanup_connections():
	if get_tree().network_peer:
		get_tree().network_peer = null
	get_tree().disconnect("connected_to_server", self, "__client_connected_to_server")

func create_server():
	cleanup_connections()
	
	rng.randomize()
	
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(PORT, MAX_PLAYERS)
	get_tree().network_peer = peer
	is_server = true
	
	print("Server created")
	
	# Initialize server's client
	__client_connected_to_server()

func join_server(ip: String):
	cleanup_connections()
	
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, PORT)
	get_tree().network_peer = peer
	is_server = false
	get_tree().connect("connected_to_server", self, "__client_connected_to_server")
	
	print("Client created")

# Run on client when connected to server
func __client_connected_to_server():
	our_id = get_tree().get_network_unique_id()
	
	rpc("request_register_client", our_profile)
