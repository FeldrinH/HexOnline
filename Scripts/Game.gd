extends Node

signal turn_start(starting_player)
signal turn_end(ending_player)

const MOVE_RANGE = 2 # tiles
const MOVES_PER_TURN = 5
const TURN_LENGTH = 5 # seconds

onready var world: Node2D = $".."
onready var timer : Timer = $Timer

onready var players : Array = $Players.get_children()

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

# Turn and permission checking utility functions
# NB: Turn checking currently disabled for debugging!
func is_active_player(compared_player: Node) -> bool:
	return true # current_player and compared_player == current_player

func is_move_allowed(calling_player: Node, owning_player: Node) -> bool:
	return calling_player == owning_player and is_active_player(calling_player)

# Networking game state on initial join
func send_state(target_id: int):
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
