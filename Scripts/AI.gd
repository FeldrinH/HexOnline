extends Node2D

var astar := preload("res://Scripts/HexAStar.gd").new()

var world: Node2D
var player: Node

var enemy_capital_tile: Node2D
var capital_tiles: Array

const last_paths := []

func init(world: Node2D, player: Node):
	self.world = world
	self.player = player
	capital_tiles = world.get_capital_tiles() 
	capital_tiles.remove(capital_tiles.find(player.capital.city_tile))
	#print("capitals", capitals)
	capital_tiles.sort_custom(self, "compare_capitals_distance")
	enemy_capital_tile = capital_tiles[0]

func compare_capitals_distance(capital_a: Node2D, capital_b: Node2D):
	if Util.distance_between_tiles(player.capital.city_tile, capital_a) < Util.distance_between_tiles(player.capital.city_tile, capital_b):
		return true
	else:
		return false

func _draw():
	#print("AI CUSTOM DRAW")
	var color = player.unit_color.darkened(0.1)
	for path in last_paths:
		var points := PoolVector2Array()
		for tile in path:
			var pos = tile.position + Vector2(rand_range(-6, 6), rand_range(-6, 6))
			points.append(pos)
			draw_circle(pos, 2.5, color)
		draw_polyline(points, color, 1.0)

# Called every time it is this AI players turn, to run AI for this player
func run_ai():
	print(player.client.profile.display_name + ": Executing turn")
	var move_count = world.game.moves_remaining
	
	if enemy_capital_tile.player == player:
		for i in len(capital_tiles):
			if capital_tiles[i].player != player:
				enemy_capital_tile = capital_tiles[i]
				break
	
	if player.capital.city_tile.army and player.capital.city_tile.army.power == 100:
		var shortest_path = find_shortest_path(player.capital.city_tile, enemy_capital_tile)
		player.capital.city_tile.army.rpc("move_to", shortest_path[1].coord)
		move_count -= 1
		last_paths.append(shortest_path)
	
	update_astar_map()
	last_paths.clear()
	
	var player_units = world.get_player_units(player)

	for unit in player_units:
		if move_count <= 0:
			break
		move_count -= 1
		
		var shortest_path = find_shortest_path(unit.tile, enemy_capital_tile)
		last_paths.append(shortest_path)
		
		if len(shortest_path) > 1:
			unit.rpc("move_to", shortest_path[1].coord)
	
	world.game.rpc("skip_turn", player.id)
	
	update()

func update_astar_map():
	astar.clear()
	
	var tiles = world.get_all_tiles()
	for tile in tiles:
		var weight = assign_weight(tile, player)
		astar.add_point(tile.id, tile.coord, weight)
	for tile in tiles:
		for travelable in world.find_travelable(tile, player, 2):
			 astar.connect_points(tile.id, travelable.id)

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