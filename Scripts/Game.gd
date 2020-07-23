extends Node

signal __move_ended()

const MOVES_PER_TURN = 5

onready var world: Node2D = $".."

var current_player : Node = null
var moves_remaining: int = 0

var __current_player_index: int = 0
var __move_active: bool = false


func get_our_player() -> Node:
	return world.network.our_client.player if world.network.our_client else null

func is_our_turn() -> bool:
	return current_player and get_our_player() == current_player

# Clientside functions for ensuring moves are run in sequence and do not overlap
func start_move():
	__move_active = true

func end_move():
	__move_active = false
	emit_signal("__move_ended")

func await_move_end():
	if __move_active:
		yield(self, "__move_ended")

# Serverside functions for managing turns (called ON server locally, will call functions on client using RPC)
func advance_move(moves_made: int):
	var new_moves_remaining = moves_remaining - moves_made
	if new_moves_remaining <= 0:
		advance_turn()
	else:
		rpc("update_moves_remaining", new_moves_remaining)
		print(moves_remaining)

func advance_turn():
	__current_player_index = (__current_player_index + 1) % len(world.players)
	rpc("start_new_turn", world.players[__current_player_index], MOVES_PER_TURN)

# Remote functions for managing turns (called FROM server ON clients using RPC)
puppetsync func update_moves_remaining(new_moves_remaining: int):
	moves_remaining = new_moves_remaining

puppetsync func start_new_turn(new_player: Node, new_moves_remaining: int):
	current_player = new_player
	moves_remaining = new_moves_remaining
	# Todo animations and stuff?

## Serverside turn functions
#puppetsync func turn_move_army():
#	if manager.current_player == self and manager.moves_remaining > 0:
#		# TODO
#		manager.advance_move()
#
#puppetsync func turn_end():
#	if manager.current_player == self:
#		manager.advance_turn()
