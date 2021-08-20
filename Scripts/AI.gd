extends Node2D

var astar := preload("res://Scripts/HexAStar.gd").new()

var mcts := MCTSManager.new()

var world: Node2D
var player: Node

var enemy_capital_tile: Node2D
var capital_tiles: Array

const last_paths := []

func init_ai(world: Node2D, player: Node):
	self.world = world
	self.player = player
	
	capital_tiles = world.get_capital_tiles() 
	capital_tiles.erase(player.capital.city_tile)
	capital_tiles.sort_custom(self, "compare_capitals_distance")
	#print("capitals", capitals)
	select_new_target_capital()
	
	setup_mcts_map()

func display_name() -> String:
	return player.client.profile.display_name

func compare_capitals_distance(capital_a: Node2D, capital_b: Node2D):
	if Util.distance_between_tiles(player.capital.city_tile, capital_a) < Util.distance_between_tiles(player.capital.city_tile, capital_b):
		return true
	else:
		return false

func select_new_target_capital():
	var capital_tiles_filtered := []
	for tile in capital_tiles:
		if !tile.city.conquered:
			capital_tiles_filtered.append(tile)
	capital_tiles = capital_tiles_filtered
	
	enemy_capital_tile = capital_tiles[0]
	
	print(display_name(), ": New target ", enemy_capital_tile.city.player.name)

func test_mcts():
	var start := OS.get_ticks_msec()
	
	setup_mcts_state()
	var move = mcts.run_mcts(1)
	last_paths.append([world.get_tile(move.from), world.get_tile(move.to)])
	
	var end := OS.get_ticks_msec()
	print("MOVE: ", move, " (", end - start, " ms)")

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

func setup_mcts_state():
	var start := OS.get_ticks_msec()
	
	mcts.reset_state(player.id, 0)
	
	for unit in world.get_all_units():
		mcts.add_unit(unit.tile.coord, unit.player.id, unit.power)
	
	for player in world.game.players:
		if !player.capital.conquered:
			mcts.add_active_player(player.id)
	
	var end := OS.get_ticks_msec()
	print("Setup state for MCTS (", end - start, " ms)")

# Called every time it is this AI player's turn, to run AI for this player
func run_ai():
	print(display_name(), ": Executing turn")
	assert(world.game.current_player == player) # Sanity check
	
	last_paths.clear()
	
	test_mcts()
	
	if enemy_capital_tile.city.conquered:
		select_new_target_capital()
	
	var move_count = world.game.moves_remaining
	var player_units: Array = world.get_player_units(player)
	
	update_astar_map()
	
	var capital_unit = player.capital.city_tile.army
	if capital_unit and capital_unit.power == 100:
		var shortest_path = find_shortest_path(player.capital.city_tile, enemy_capital_tile)
		capital_unit.rpc("move_to", shortest_path[1].coord)
		yield(get_tree().create_timer(0.25), "timeout")
		move_count -= 1
		player_units.erase(capital_unit)
		last_paths.append(shortest_path)
	
	for unit in player_units:
		if move_count <= 0:
			break
		move_count -= 1
		
		var shortest_path = find_shortest_path(unit.tile, enemy_capital_tile)
		last_paths.append(shortest_path)
		
		if len(shortest_path) > 1:
			unit.rpc("move_to", shortest_path[1].coord)
			yield(get_tree().create_timer(0.25), "timeout")
	
	if move_count > 0:
		world.game.rpc("skip_turn", player.id)
	
	update()

func update_astar_map():
	astar.clear()
	
	var tiles = world.get_all_tiles()
	
	for tile in tiles:
		if !tile.blocked:
			var weight = assign_weight(tile, player)
			astar.add_point(tile.id, tile.coord, weight)
	
	for tile in tiles:
		if !tile.blocked:
			for travelable in world.find_travelable(tile, player, 2):
				 astar.connect_points(tile.id, travelable.id, false)

func find_shortest_path(start, target) -> Array:
	var path = astar.get_id_path(start.id, target.id)
	
	var tile_path = []
	for i in path:
		tile_path.append(world.get_tile_by_id(i))
	
	return tile_path
	
func assign_weight(given_tile, player) -> float:
	if given_tile.army and given_tile.player != player:
		return 1.0
	elif given_tile.city:
		return 2.0 + rand_range(-1, 1)
	for tile in world.find_travelable(given_tile, player, 2):
		if tile.army and tile.player != player:
			return 1.2
		elif tile.city:
			return 3.0
	return 4.0 + rand_range(-2, 2)

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
