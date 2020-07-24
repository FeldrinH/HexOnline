const city_names = []
const port_names = ["New York", "Portland", "San Franscisco"]

static func generate_map(map):
	var tiles = map.get_all_tiles()

	randomize()
	
	for tile in tiles:
		tile.set_terrain(Util.TERRAIN_GROUND)
	
	var seatiles = [map.get_tile(Vector2(15, 1))]
	
	while seatiles.size() < 60:
		var expand_at = Util.pick_random(seatiles)
		var neighbor = Util.pick_random(map.find_neighbours(expand_at))
		if neighbor.terrain != Util.TERRAIN_WATER:
			neighbor.set_terrain(Util.TERRAIN_WATER)
			seatiles.append(neighbor)
	
	var noise = OpenSimplexNoise.new()
	noise.octaves = 2
	noise.period = 400
	noise.seed = randi()
	
	for tile in tiles:
		if noise.get_noise_2dv(tile.position) > 0.4:
			tile.set_terrain(Util.TERRAIN_WATER)

	for tile in tiles:
		if is_single_tile_island(tile, map):
			tile.set_terrain(Util.TERRAIN_WATER)

	var best_min_distance = 0
	var best_total_distance = 0
	var best_capitals = null
	for i in 100000:
		var try_min_distance = 100000
		var try_total_distance = 0
		var try_capitals = []
		for player in map.game.players:
			var try_tile = find_spawnable(tiles, 20)
			if try_tile:
				for capital_tile in try_capitals:
					var new_distance = map.distance_between(try_tile, capital_tile)
					try_min_distance = min(new_distance, try_min_distance)
					try_total_distance += new_distance
					if try_min_distance < best_min_distance:
						break
				try_capitals.append(try_tile)
			else:
				break
		if (try_min_distance > best_min_distance or (try_min_distance == best_min_distance and try_total_distance > best_total_distance)) and len(try_capitals) == len(map.game.players):
			best_min_distance = try_min_distance
			best_total_distance = try_total_distance
			best_capitals = try_capitals
			print(str(best_min_distance) + "  " + str(best_total_distance))
	
	for i in len(map.game.players):
		best_capitals[i].add_capital(map.game.players[i])
	
	var file = File.new()
	file.open("res://Scripts/city_names.csv", file.READ)
	
	var temp_cities = []
	
	while !file.eof_reached():
		temp_cities.append(file.get_line())
	file.close()
	
	# Picks 10 random city names from list
	for i in 10:
		var index = randi() % temp_cities.size()
		city_names.append(temp_cities[index])
		temp_cities.remove(index)
	
	# Adds cities
	for name in city_names:
		var try_tile = find_spawnable(tiles, 10)
		if try_tile != null:
			try_tile.add_city(name)
	
	# Adds ports
	for port_name in port_names:
		var try_tile = find_spawnable(find_coast(map, seatiles), 10)
		if try_tile != null:
			try_tile.add_city(port_name)
			try_tile.city.make_port()

static func is_single_tile_island(tile, map) -> bool:
	for neighbour in map.find_neighbours(tile):
		if neighbour.terrain == Util.TERRAIN_GROUND:
			return false
	return true

static func find_spawnable(tiles : Array, max_attempts : int) -> Node:
	for i in max_attempts:
		var try_tile = Util.pick_random(tiles)
		if try_tile.terrain == Util.TERRAIN_GROUND and !try_tile.blocked and try_tile.city == null:
			return try_tile
	return null

static func find_coast(map, seatiles) -> Array:
	var coast_tiles = []
	for seatile in seatiles:
		var neighbors = map.find_neighbours(seatile)
		for tile in neighbors:
			if tile.terrain == Util.TERRAIN_GROUND and !tile.blocked:
				coast_tiles.append(tile)
	return coast_tiles


#static func check_for_capital(nearby_tiles) -> bool:
#	for key in nearby_tiles.keys():
#		print (typeof(key.city))
#		key.city = Capital
#		print("muna")
##		if key.city != null and typeof(key.city) == Capital:
##			return false
#	return true
