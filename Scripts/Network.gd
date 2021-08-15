extends Node

signal client_connected(id, client) # Emitted on all clients/server after a new client has connected
signal client_disconnected(id, client)
signal client_initializing(id, client) # Emitted on server when client is connecting, when initial data should be sent
signal client_initialized() # Emitted on client/server after local client has fully initialized

const Client = preload("res://Client.tscn")

const PORT = 2000
const MAX_CLIENTS = 8

const SERVER_ID = 1 # Server always has networking id 1 in Godot

onready var world: Node = $".."

var our_client: Node # Exists on client_connecting
var is_connected: bool = false # True on our_client_connected
var is_server: bool = false
var clients: Dictionary = {}
var __next_ai_id: int = -100

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var __next_id: int = 0

# Networking utility functions for use during game
# Increments and returns the value of a synchronized counter
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

func select_player_for_client(client_id: int, player_id: int):
	get_client(client_id).rpc("select_player", player_id)

func get_our_player() -> Node:
	return our_client.player

# Gets id of ai client for given player
func create_ai_client_for_player(player_id: int, profile: Dictionary) -> int:
	var client_id := - (100 + player_id)
	
	if clients.has(client_id):
		deregister_ai_client(client_id)
	register_ai_client(client_id, profile)
	
	return client_id

# Get player for client who sent the active RPC.
# NB: Messages sent from the server by AI will return the server's player, not the AI's player
# func get_rpc_sender_player() -> Node:
#	return get_client(get_tree().get_rpc_sender_id()).player

# Check if RPC sender is allowed to act as current player
static func can_client_act_as_player(client_id: int, target_player: Node) -> bool:
	if client_id == SERVER_ID:
		return true # Server can act as any player
	else:
		return target_player.client and target_player.client.id == client_id

# Networking RPC functions
# Run on server when new client announces itself
master func register_client(profile: Dictionary):
	var id = get_tree().get_rpc_sender_id()
	if !clients.has(id):
		print("SERVER: New client registered: " + profile.display_name + " (" + str(id) + ")")
		
		rpc("add_remote_client", id, profile, -1)
		
		if id != get_tree().get_network_unique_id():
			initialize_client(id)
		
		rpc_id(id, "client_initialized")

# Run on server to add and sync new AI client
func register_ai_client(id: int, profile: Dictionary) -> int:
		assert(is_server)
		assert(id < 0)
		
		print("SERVER: New ai client registered: " + profile.display_name + " (" + str(id) + ")")
		
		rpc("add_remote_client", id, profile, -1)
		
		return id

func deregister_ai_client(id: int):
		assert(is_server)
		assert(id < 0) # Sanity check: Only allow removing AI clients
		
		print("SERVER: AI client removed: " + str(id))
		
		rpc("remove_remote_client", id)

func initialize_client(id: int):
	assert(id > 0) # Sanity check: id should never correspond to broadcast (0) or AI (negative)
	
	for client in clients.values():
		rpc_id(id, "add_remote_client", client.id, client.profile, client.player.id if client.player else -1)
	
	# Wait for active moves to end, because moving units cannot be sent
	var __ = world.game.await_start_move("initialize_client")
	if __ is GDScriptFunctionState:
		yield(__, "completed")
	
	world.send_map(id)
	world.game.send_state(id)
	emit_signal("client_initializing", id, get_client(id))
	rpc_id(id, "set_synced_values", rng.seed, __next_id)
	
	world.game.end_move("initialize_client")

puppetsync func add_remote_client(id: int, profile: Dictionary, player_id: int):
	if !clients.has(id):
		print("CLIENT: New client registered: " + profile.display_name + " (" + str(id) + ")")
		
		var new_client = Client.instance()
		new_client.init(world, id, profile, player_id)
		add_child(new_client)
		
		clients[id] = new_client
		if id == get_tree().get_network_unique_id():
			our_client = new_client
		
		emit_signal("client_connected", id, new_client)

# Used to run cleanup when client disconnects
puppetsync func remove_remote_client(id: int):
	if clients.has(id):
		var old_client = clients[id]
		print("CLIENT: New client deregistered: " + old_client.profile.display_name + " (" + str(id) + ")")
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
	get_tree().disconnect("network_peer_disconnected", self, "_server_on_client_disconnected")
	get_tree().disconnect("connected_to_server", self, "_client_on_connected_to_server")
	get_tree().disconnect("connection_failed", self, "_client_on_connection_failed")
	get_tree().disconnect("server_disconnected", self, "_client_on_server_disconnected")

func create_server(our_profile: Dictionary):
	cleanup_connections()
	
	rng.randomize()
	
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(PORT, MAX_CLIENTS)
	get_tree().network_peer = peer
	is_server = true
	get_tree().connect("network_peer_disconnected", self, "_server_on_client_disconnected")
	
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
	get_tree().connect("connection_failed", self, "_client_on_connection_failed")
	get_tree().connect("server_disconnected", self, "_client_on_server_disconnected")
	
	print("Client created")

# Run on client when connected to server
func _client_on_connected_to_server(our_profile: Dictionary):
	rpc("register_client", our_profile)

func _client_on_connection_failed():
	print("CLIENT: Connection failed")

func _client_on_server_disconnected():
	print("CLIENT: Server disconnected")

func _server_on_client_disconnected(id: int):
	print("SERVER: Client disconnected: " + str(id))
	
	rpc("remove_remote_client", id)
