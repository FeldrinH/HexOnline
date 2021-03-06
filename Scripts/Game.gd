extends Node

signal current_player_changed(new_active_player)
signal moves_remaining_changed(new_moves_remaining)
signal players_changed()
#signal game_won(winner)
signal __move_ended()

const MOVE_RANGE = 2 # tiles
const MOVES_PER_TURN = 5
const TURN_LENGTH = 15 # seconds
const TURN_REINFORCEMENTS = 10

onready var world: Node2D = $".."
onready var timer : Timer = $Timer

onready var __all_players: Array = $Players.get_children()
onready var players: Array = __all_players

var winner: Node = null
var current_player : Node = null
var current_turn: int = -1
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
	return __all_players[id] if id >= 0 else null

func get_selected_players_count() -> int:
	var count := 0
	for player in __all_players:
		if player.client:
			count += 1
	return count

func remove_unselected_players():
	for player in __all_players:
		if player.client:
			player.selectable = true
		else:
			player.selectable = false
	__send_update_players(0)

func __send_update_players(target_id: int):
	var selectable_values := []
	for player in __all_players:
		selectable_values.append(player.selectable)
	rpc_id(target_id, "__update_players", selectable_values)

puppetsync func __update_players(selectable_values: Array):
	players = []
	for player in __all_players:
		player.selectable = selectable_values[player.id]
		if player.selectable:
			players.append(player)
	emit_signal("players_changed")

# Turn and permission checking utility functions
# NB: Turn checking currently disabled for debugging!
func is_active_player(compared_player: Node) -> bool:
	return current_player and compared_player == current_player and moves_remaining > 0

func is_move_allowed(calling_player: Node, move_unit: Node) -> bool:
	return move_unit.player == calling_player and move_unit.last_turn != current_turn and is_active_player(calling_player)

# Networking game state on initial join
func send_state(target_id: int):
	__send_update_players(target_id)
	if current_player:
		rpc_id(target_id, "advance_turn_to", current_player.id, moves_remaining, timer.time_left)

# Turn management functions
# Call on client at the end of every move
func advance_move():
	advance_move_to(moves_remaining - 1)

# Call on server at end of turn
func call_advance_turn():
	var current_player_index := players.find(current_player)
	
	current_player_index = (current_player_index + 1) % len(players)
	while players[current_player_index].capital.conquered:
		current_player_index = (current_player_index + 1) % len(players)
	
	rpc("advance_turn", players[current_player_index].id, MOVES_PER_TURN)

# Call by RPC at start of game
puppetsync func start_game():
	var __ = await_start_move()
	if __ is GDScriptFunctionState:
		yield(__, "completed")
	
	advance_turn_to(players[0].id, MOVES_PER_TURN)
	add_forces(players[0].id)
	current_turn = 0
	world.effects.play_sound("game_start")
	
	end_move()

# Call by RPC at end of turn
puppetsync func advance_turn(new_player_id, new_moves_remaining):
	var __ = await_start_move()
	if __ is GDScriptFunctionState:
		yield(__, "completed")
	
	print(new_player_id, new_moves_remaining)
	advance_turn_to(new_player_id, new_moves_remaining)
	add_forces(new_player_id)
	current_turn += 1
	
	end_move()

# Call by RPC from client on server to request turn skip
master func skip_turn():
	var sender_player = world.network.get_rpc_sender_player()
	var __ = await_start_move()
	if __ is GDScriptFunctionState:
		yield(__, "completed")
	
	if is_active_player(sender_player):
		call_advance_turn()
	
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
	
	var all_units = world.get_all_units()
	var current_player_units = []
	for unit in all_units:
		if unit.player and unit.player == current_player:
			unit.set_moveable_sprite(true)
				
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

func __find_winner() -> Node:
	var remaining_player = null
	for player in players:
		if !player.capital.conquered:
			if remaining_player:
				return null
			remaining_player = player
	return remaining_player

# Called on server when a player loses
func player_lost(loser: Node, conqueror: Node):
	loser.rpc("do_loss", conqueror.id)
	
	rpc("announce_loser", loser.id)
	var found_winner = __find_winner()
	if found_winner:
		rpc("announce_winner", found_winner.id)

puppetsync func announce_loser(loser_id: int):
	world.effects.play_sound("conquer_announce")
	var loser = get_player(loser_id)

	if loser == world.network.get_our_player():
		world.ui.hide("Overlay")
		world.ui.hide("DebugMenu")
		world.ui.show("LossScreen")

puppetsync func announce_winner(winner_id: int):
	winner = get_player(winner_id)
	world.ui.hide("Overlay")
	world.ui.hide("DebugMenu")
	world.ui.hide("LossScreen")
	world.ui.show("WinScreen")
	world.ui.get_node("WinScreen").display_winner_name(winner.name)

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
	if world.network.is_server and (new_moves_remaining <= 0 or !current_player.client):
		call_advance_turn()

func __on_turn_timer_timeout():
	if world.network.is_server:
		call_advance_turn()
