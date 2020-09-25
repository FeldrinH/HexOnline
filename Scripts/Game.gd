extends Node

signal current_player_changed(new_active_player)
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
	if current_player:
		rpc_id(target_id, "advance_turn_to", current_player.id, moves_remaining, timer.time_left)

# Turn management functions
# Call on client at the end of every move
func advance_move():
	advance_move_to(moves_remaining - 1)

# Call by RPC at end of turn
puppetsync func advance_turn(new_player_id, new_moves_remaining):
	var __ = await_start_move()
	if __ is GDScriptFunctionState:
		yield(__, "completed")
	
	advance_turn_to(new_player_id, new_moves_remaining)
	add_forces(new_player_id)
	
	rpc("add_forces", current_player.id)
	
	end_move()

# Call by RPC at start of game
puppetsync func start_game():
	var __ = await_start_move()
	if __ is GDScriptFunctionState:
		yield(__, "completed")
	
	advance_turn_to(0, MOVES_PER_TURN)
	add_forces(0)
	
	end_move()

# Utility functions for turn management
func advance_move_to(new_moves_remaining: int):
	moves_remaining = new_moves_remaining
	
	emit_signal("moves_remaining_changed", moves_remaining)
	
	print(str(moves_remaining) + " moves remaining")

puppetsync func advance_turn_to(new_player_id: int, new_moves_remaining: int, new_turn_lenght: int = TURN_LENGTH):
	current_player = get_player(new_player_id)
	moves_remaining = new_moves_remaining
	
	emit_signal("current_player_changed", current_player)
	emit_signal("moves_remaining_changed", moves_remaining)
	
	timer.start(new_turn_lenght)
	
	print("Turn advanced to player " + current_player.name)

func add_forces(player_id: int):
	var player = get_player(player_id)
	
	for unit in world.get_all_units():
		if unit.player == player and unit.tile.city:
			if unit.tile.city.is_capital and !unit.tile.city.conquered:
				unit.set_power(min(unit.power + 20, unit.MAX_POWER), true)
			else:
				unit.set_power(min(unit.power + 10, unit.MAX_POWER), true)
	
	if !player.capital.city_tile.army and !player.capital.conquered:
		world.add_unit(player.capital.city_tile.coord, 20, player.id, false)

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
		rpc("advance_turn", (current_player.id + 1) % len(players), MOVES_PER_TURN)

func __on_turn_timer_timeout():
	if world.network.is_server:
		rpc("advance_turn", (current_player.id + 1) % len(players), MOVES_PER_TURN)
