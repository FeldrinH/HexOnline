extends Node

signal player_selected(client_id, player)
signal __move_ended()

const MOVE_RANGE = 2 # tiles
const MOVES_PER_TURN = 5
const TURN_LENGTH = 5 # seconds

onready var world: Node2D = $".."
onready var timer : Timer = $Timer

onready var players : Array = $Players.get_children()
var our_player: Node = null

onready var current_player : Node = players[0]
var moves_remaining: int = MOVES_PER_TURN

#var __current_player_index: int = 0
var __cur_move_index: int = 0
var __next_free_move_index: int = 0

func _ready():
	for i in len(players):
		players[i].init(world, i)

func get_player(id: int) -> Node:
	return players[id] if id >= 0 else null

# NB: Slow
func find_player_by_client(client_id: int) -> Node:
	for player in players:
		if player.client_id == client_id:
			return player
	return null

puppetsync func select_player(client_id: int, player_id: int):
	var old_player = find_player_by_client(client_id)
	if old_player:
		old_player.client_id = -1
	
	var player = get_player(player_id)
	if player:
		player.client_id = client_id
	if client_id == Network.our_id:
		our_player = player
	emit_signal("player_selected", client_id, player)

master func request_select_player(player_id: int):
	if get_player(player_id).client_id == -1:
		rpc("select_player", Network.get_rpc_sender_id(), player_id)

# Turn and permission checking utility functions
# NB: Turn checking currently disabled for debugging!
func is_active_player(compared_player: Node) -> bool:
	return true # current_player and compared_player == current_player

func is_move_allowed(calling_client_id: int, owning_player: Node) -> bool:
	return calling_client_id == owning_player.client_id and is_active_player(owning_player)

# Networking game state on initial join
func send_state(target_id: int):
	for player in players:
		player.rpc_id(target_id, "select_player", player.client_id)
	rpc_id(target_id, "advance_turn_to", current_player.id if current_player else -1, moves_remaining)

# Turn management functions
func advance_move(moves_made: int):
	moves_remaining -= moves_made
	if moves_remaining <= 0:
		advance_turn_to((current_player.id + 1) % len(players), MOVES_PER_TURN)
	print("Moves remaining: " + str(moves_remaining))

puppet func advance_turn_to(new_player_id: int, new_moves_remaining: int):
	current_player = get_player(new_player_id)
	moves_remaining = new_moves_remaining
	print("Turn advanced to player " + current_player.name)

# Clientside functions for ensuring moves are run in sequence and do not overlap
func await_start_move():
	var this_move_index = __next_free_move_index
	__next_free_move_index += 1
	
	while __cur_move_index < this_move_index:
		yield(self, "__move_ended")
	
	assert(__cur_move_index == this_move_index) # Sanity check

func end_move():
	__cur_move_index += 1
	assert(__cur_move_index <= __next_free_move_index) # Sanity check
	emit_signal("__move_ended")

func is_move_active():
	return __cur_move_index < __next_free_move_index
