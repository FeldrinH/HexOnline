extends Node

signal __move_ended()

const MOVE_RANGE = 2
const MOVES_PER_TURN = 5

onready var world: Node2D = $".."
onready var players : Array = $Players.get_children()

onready var current_player : Node = players[0]
var moves_remaining: int = MOVES_PER_TURN

var __current_player_index: int = 0
var __cur_move_index: int = 0
var __next_free_move_index: int = 0

func _ready():
	for i in len(players):
		players[i].init(world, i)

func get_player(id: int):
	return players[id] if id >= 0 else null

func get_our_player() -> Node:
	return world.network.our_client.player if world.network.our_client else null

# Turn and permission checking utility functions
# NB: Turn checking currently disabled for debugging!

func is_our_move_allowed(owning_player: Node) -> bool:
	return owning_player.client == world.network.our_client # and owning_player == current_player

func is_rpc_sender_move_allowed(owning_player: Node) -> bool:
	return owning_player.client and owning_player.client.id == get_tree().get_rpc_sender_id() # and owning_player == current_player

#func is_our_turn():
#	return true # current_player and current_player.client == world.network.our_client

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

func advance_move(moves_made: int):
	moves_remaining -= moves_made
	if moves_remaining <= 0:
		advance_turn()
	print("Moves remaining: " + str(moves_remaining))

func advance_turn():
	__current_player_index = (__current_player_index + 1) % len(players)
	current_player = players[__current_player_index]
	moves_remaining = MOVES_PER_TURN
	print("Turn advanced to player " + current_player.name)
	

## Serverside functions for managing turns (called ON server locally, will call functions on client using RPC)
#func advance_move(moves_made: int):
#	var new_moves_remaining = moves_remaining - moves_made
#	if new_moves_remaining <= 0:
#		advance_turn()
#	else:
#		rpc("update_moves_remaining", new_moves_remaining)
#		print(moves_remaining)
#
#func advance_turn():
#	__current_player_index = (__current_player_index + 1) % len(world.players)
#	rpc("start_new_turn", world.players[__current_player_index], MOVES_PER_TURN)
#
## Remote functions for managing turns (called FROM server ON clients using RPC)
#puppetsync func update_moves_remaining(new_moves_remaining: int):
#	moves_remaining = new_moves_remaining
#
#puppetsync func start_new_turn(new_player: Node, new_moves_remaining: int):
#	current_player = new_player
#	moves_remaining = new_moves_remaining
#	# Todo animations and stuff?
