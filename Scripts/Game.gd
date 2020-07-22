extends Node

signal move_ended()

onready var world: Node2D = $".."

var current_player : Node = null
var moves_remaining: int = 0
var move_active: bool = false

func _ready():
	current_player = world.get_node("Players").get_children()[0]

func get_our_player() -> Node:
	return world.network.our_client.player if world.network.our_client else null

func is_our_turn() -> bool:
	return current_player and get_our_player() == current_player

# Clientside functions for synchronizing moves
func start_move():
	move_active = true

func end_move():
	move_active = false
	emit_signal("move_ended")

func await_move_end():
	if move_active:
		yield(self, "move_ended")

# Serverside functions for managing turns
puppetsync func advance_move(move_num: int):
	moves_remaining -= move_num
	if moves_remaining <= 0:
		advance_turn()

puppetsync func advance_turn():
	# TODO: End turn logic here
	pass

## Serverside turn functions
#puppetsync func turn_move_army():
#	if manager.current_player == self and manager.moves_remaining > 0:
#		# TODO
#		manager.advance_move()
#
#puppetsync func turn_end():
#	if manager.current_player == self:
#		manager.advance_turn()
