extends Node

signal turn_changed(new_active_player)
signal moves_remaining_changed(new_moves_remaining)
signal __move_ended()

const MOVE_RANGE = 2 # tiles
const MOVES_PER_TURN = 5
const TURN_LENGTH = 15 # seconds
const TURN_REINFORCEMENTS = 10

onready var world: Node2D = $".."
onready var timer : Timer = $Timer

onready var __all_players: Array = $Players.get_children()
onready var players: Array = __all_players

onready var current_player : Node = null
var moves_remaining: int = MOVES_PER_TURN

#var __current_player_index: int = 0
var __cur_move_index: int = 0
var __next_free_move_index: int = 0

func _ready():
	for i in len(players):
		players[i].init(world, i)
	timer.connect("timeout", self, "__on_turn_timer_timeout")
	connect("moves_remaining_changed", self, "__on_moves_remaining_changed")
	connect("turn_changed", self, "add_forces")
	
func get_player(id: int) -> Node:
	return players[id] if id >= 0 else null

func set_player_count(count: int):
	players = __all_players.slice(0, count)

# Turn and permission checking utility functions
# NB: Turn checking currently disabled for debugging!
func is_active_player(compared_player: Node) -> bool:
	return true # current_player and compared_player == current_player and moves_remaining > 0

func is_move_allowed(calling_player: Node, owning_player: Node) -> bool:
	return calling_player == owning_player and is_active_player(calling_player)

# Networking game state on initial join
func send_state(target_id: int):
	rpc_id(target_id, "advance_turn_to", current_player.id if current_player else -1, moves_remaining)

# RPCs for game events and actions
puppetsync func start_game():
	advance_turn_to(0, MOVES_PER_TURN)

# Turn management functions
# Call on client at the end of every move
func advance_move():
	advance_move_to(moves_remaining - 1)

# Call on server at end of turn
func advance_turn():
	rpc("advance_turn_to", (current_player.id + 1) % len(players), MOVES_PER_TURN)

func advance_move_to(new_moves_remaining: int):
	moves_remaining = new_moves_remaining
	
	emit_signal("moves_remaining_changed", moves_remaining)
	
	print(str(moves_remaining) + " moves remaining")

puppetsync func advance_turn_to(new_player_id, new_moves_remaining: int, new_turn_lenght: int = TURN_LENGTH):
	var __ = await_start_move()
	if __ is GDScriptFunctionState:
		yield(__, "completed")
	
	current_player = get_player(new_player_id)
	moves_remaining = new_moves_remaining
	
	emit_signal("turn_changed", current_player)
	emit_signal("moves_remaining_changed", moves_remaining)
	
	timer.start(new_turn_lenght)
	
	print("Turn advanced to player " + current_player.name)
	
	end_move()

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

# Event handlers
func __on_moves_remaining_changed(new_moves_remaining: int):
	if world.network.is_server and new_moves_remaining <= 0:
		advance_turn()

func __on_turn_timer_timeout():
	if world.network.is_server:
		advance_turn()

func add_forces(player):
	for i in world.get_all_units():
		if i.tile.city and !i.tile.city.is_capital:
			if i.power + TURN_REINFORCEMENTS <= 100:
				i.set_power(i.power + 10, true)
			else:
				i.set_power(i.MAX_POWER, false)
		elif i.tile.city and i.tile.city.is_capital:
			if i.power + 20 <= 100:
				i.set_power(i.power + 20, true)
			else:
				i.set_power(i.MAX_POWER, false)
	if !player.capital.city_tile.army:
		world.add_unit(player.capital.city_tile.coord, 20, player.id, true)	
