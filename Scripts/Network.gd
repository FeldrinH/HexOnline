extends Node

signal client_connected(id, client) # Emitted on all clients/server after a new client has connected
signal client_initializing(id, client) # Emitted on server when client is connecting, when initial data should be sent
signal client_initialized() # Emitted on client/server after local client has fully initialized

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

func select_player(player_id: int):
	our_client.rpc("select_player", player_id)

func get_our_player() -> Node:
	return our_client.player

func get_rpc_sender_player() -> Node:
	return get_client(get_tree().get_rpc_sender_id()).player

# Networking RPC functions
# Run on server when new client announces itself
master func register_client(profile: Dictionary):
	var id = get_tree().get_rpc_sender_id()
	if !clients.has(id):
		print("SERVER: New client connected: " + str(id))
		
		rpc("add_remote_client", id, profile, -1)
		
		if id != get_tree().get_network_unique_id():
			initialize_client(id)
		
		rpc_id(id, "client_initialized")

func initialize_client(id: int):
	for client in clients.values():
		rpc_id(id, "add_remote_client", client.id, client.profile, client.player.id if client.player else -1)
		
	world.send_map(id)
	world.game.send_state(id)
	emit_signal("client_initializing", id, get_client(id))
	
	rpc_id(id, "set_synced_values", rng.seed, __next_id)

puppetsync func add_remote_client(id: int, profile: Dictionary, player_id: int):
	if !clients.has(id):
		print("CLIENT: New client connected: " + profile.display_name)
		
		var new_client = Client.instance()
		new_client.init(world, id, profile, player_id)
		add_child(new_client)
		clients[id] = new_client
		
		if id == get_tree().get_network_unique_id():
			our_client = new_client
		
		emit_signal("client_connected", id, new_client)

# Used to run cleanup when client disconnects
func remove_remote_client(id: int):
	if clients.has(id):
		print("CLIENT: Client disconnected: " + get_client(id).profile.display_name)
		
		var old_client = clients[id]
		old_client.cleanup()
		clients.erase(id)
		emit_signal("client_disconnected", id, old_client)

puppetsync func set_synced_values(rng_seed: int, next_id: int):
	rng.set_seed(rng_seed)
	__next_id = next_id

puppetsync func client_initialized():
	is_connected = true
	emit_signal("client_initialized")
	
	print("CLIENT: Our client initialized: " + str(our_client.id))

# Server lifecycle functions
func cleanup_connections():
	if get_tree().network_peer:
		get_tree().network_peer = null
	get_tree().disconnect("connected_to_server", self, "_client_on_connected_to_server")
	get_tree().disconnect("network_peer_disconnected", self, "_server_on_client_disconnected")

func create_server(our_profile: Dictionary):
	cleanup_connections()
	
	rng.randomize()
	
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(PORT, MAX_CLIENTS)
	get_tree().network_peer = peer
	is_server = true
	get_tree().connect("network_peer_disconnected ", self, "_server_on_client_disconnected")
	
	# Initialize server's client
	_client_on_connected_to_server(our_profile)
	
	print("Server created")

func join_server(ip: String, our_profile: Dictionary):
	cleanup_connections()
	
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, PORT)
	get_tree().network_peer = peer
	is_server = false
	get_tree().connect("connected_to_server", self, "_client_on_connected_to_server", [our_profile])
	
	print("Client created")

# Run on client when connected to server
func _client_on_connected_to_server(our_profile: Dictionary):
	rpc("register_client", our_profile)

func _server_on_client_disconnected(id: int):
	print("SERVER: Client disconnected: " + str(id))
	
	rpc("remove_client", id)
