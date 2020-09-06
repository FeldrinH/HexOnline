extends Node

signal connection_finalized()

const PORT = 2000
const MAX_PLAYERS = 4

const Client = preload("res://Client.tscn")

onready var world: Node2D = $".."

var clients: Dictionary = {}
var our_client: Node = null
var is_server: bool = false

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var __next_id: int = 0

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

master func request_add_client(id: int, display_name: String, player_id: int):
	if get_tree().get_rpc_sender_id() == id:
		rpc("add_client", id, display_name, player_id)
		print("Joined: " + display_name)

puppetsync func add_client(id: int, display_name: String, player_id: int) -> Node:
	if clients.has(id):
		return clients[id] # Client exists
	
	var client = Client.instance()
	client.init(world, id, display_name, world.game.get_player(player_id))
	add_child(client)
	clients[id] = client
	
	return client

puppetsync func set_synced_values(rng_seed: int, next_id: int):
	rng.set_seed(rng_seed)
	__next_id = next_id

puppetsync func connection_finalized():
	emit_signal("connection_finalized")

func cleanup_connections():
	if get_tree().network_peer:
		get_tree().network_peer = null
	get_tree().disconnect("network_peer_connected", self, "__server_peer_connected")
	get_tree().disconnect("connected_to_server", self, "__client_connected_to_server")

func create_server(client_display_name: String):
	cleanup_connections()
	
	world.generate_map()
	rng.randomize()
	
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(PORT, MAX_PLAYERS)
	get_tree().network_peer = peer
	is_server = true
	get_tree().connect("network_peer_connected", self, "__server_peer_connected")
	
	print("Server created")
	
	# Initialize server's client
	__client_connected_to_server(client_display_name)
	connection_finalized()

func join_server(ip: String, client_display_name: String):
	cleanup_connections()
	
	world.map_cleanup()
	
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
		rpc_id(id, "add_client", client.id, client.display_name, client.player.id if client.player else -1)
	world.send_map(id)
	world.game.send_state(id)
	rpc_id(id, "set_synced_values", rng.seed, __next_id)
	rpc_id(id, "connection_finalized")
	
	print("Peer connected: " + str(id))

# Run on client when connected to server
func __client_connected_to_server(client_display_name: String):
	var id = get_tree().get_network_unique_id()
	our_client = add_client(id, client_display_name, -1)
	rpc("request_add_client", id, client_display_name, -1)
	
	print("Connected to server: " + str(id))
