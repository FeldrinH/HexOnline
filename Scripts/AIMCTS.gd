extends Node2D

var mcts := MCTSManager.new()

var world: Node2D
var player: Node

const last_paths := []

func init_ai(world: Node2D, player: Node):
	self.world = world
	self.player = player
	
	setup_mcts_map()
	
	print(display_name(), ": Setup AI systems")

func display_name() -> String:
	return "[AI MCTS] " + player.name

func setup_mcts_map():
	#var start := OS.get_ticks_msec()
	
	mcts.set_our_player(player.id)
	
	for tile in world.get_all_tiles():
		if !tile.blocked:
			mcts.add_tile(tile.coord, tile.terrain)
			if tile.city:
				if tile.city.is_capital:
					mcts.add_capital(tile.coord, tile.city.player.id)
				else:
					mcts.add_city(tile.coord, tile.city.is_port)
	
	#var end := OS.get_ticks_msec()
	#print("Setup terrain for MCTS (", end - start, " ms)")

func setup_mcts_state(moves_made: int):
	#var start := OS.get_ticks_msec()
	
	mcts.reset_state(player.id, moves_made)
	
	for unit in world.get_all_units():
		mcts.add_unit(unit.tile.coord, unit.player.id, unit.power, has_unit_moved_this_turn(unit))
	
	for player in world.game.players:
		if !player.capital.conquered:
			mcts.add_active_player(player.id)
	
	#var end := OS.get_ticks_msec()
	#print(display_name(), ": Setup state for MCTS (", end - start, " ms)")

# Called every time it is this AI player's turn, to run AI for this player
func run_ai():
	print(display_name(), ": Executing turn")
	assert(world.game.current_player == player) # Sanity check
	
	last_paths.clear()
	
	var move_count = world.game.moves_remaining
	while move_count > 0:
		# Wait for all units to move, so we have next state
		var __ = world.game.await_start_move("ai_wait_for_move_end")
		if __ is GDScriptFunctionState:
			if yield(__, "completed"): assert(false)
		world.game.end_move("ai_wait_for_move_end")
		
		if !has_moveable_units():
			break
		
		var start := OS.get_ticks_msec()
		setup_mcts_state(5 - move_count)
		var best_move = mcts.run_mcts(50000, 15)
		var end := OS.get_ticks_msec()
		print(display_name(), ": Ran MCTS for best move (", end - start, " ms)")
		
		if best_move.skip:
			break
		else:
			var unit = world.get_tile(best_move.from).army
			assert(unit.player == player)
			
			unit.rpc("move_to", best_move.to)
			move_count -= 1
			last_paths.append([world.get_tile(best_move.from), world.get_tile(best_move.to)])
			update()
			
			yield(get_tree().create_timer(0.2), "timeout")
	
	if move_count > 0:
		world.game.rpc("skip_turn", player.id)

func has_unit_moved_this_turn(unit: Node2D) -> bool:
	return unit.last_turn == world.game.current_turn

func has_moveable_units() -> bool:
	for unit in world.get_player_units(player):
		if !has_unit_moved_this_turn(unit):
			return true
	return false

func _draw():
	#print("AI CUSTOM DRAW")
	var color: Color = player.unit_color.darkened(0.1)
	color.a = 0.75
	for path in last_paths:
		var points := PoolVector2Array()
		for i in len(path):
			var pos = path[i].position + Vector2(rand_range(-6, 6), rand_range(-6, 6))
			points.append(pos)
			draw_circle(pos, max(4.0 - i, 2.0), color)
		if len(points) > 1:
			draw_polyline(points, color, 1.0)
