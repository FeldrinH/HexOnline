static func random_seed() -> int:
	var seed_rng := RandomNumberGenerator.new()
	seed_rng.randomize()
	return seed_rng.seed

static func generate_map(map: Node):
	print("MAPGEN: Started")
	while true:
		map.clear_map()
		
		var tiles = map.get_all_tiles()
		
		var new_seed := random_seed()
		seed(new_seed)
		print("MAPGEN: Generating map with seed ", new_seed)
		
		for tile in tiles:
			tile.set_terrain(Util.TERRAIN_GROUND)
			tile.set_type(Util.TYPE_REGULAR)
		
		yield()
		
		var seagen_tiles = [map.get_tile(Vector2(15, 1))]
		
		while seagen_tiles.size() < 60:
			var expand_at = Util.pick_random(seagen_tiles)
			var neighbor = Util.pick_random(map.find_neighbours(expand_at))
			if neighbor.terrain != Util.TERRAIN_WATER:
				neighbor.set_terrain(Util.TERRAIN_WATER)
				seagen_tiles.append(neighbor)
		
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
		
		var file = File.new()
		file.open("res://Data/city_names.txt", File.READ)
		
		var temp_cities = []
		
		while !file.eof_reached():
			temp_cities.append(file.get_line())
		file.close()
		
		var coast_tiles = find_coast(tiles)
		var inland_tiles = find_inland(tiles)
		
		yield()
		
		var best_min_distance = 0
		var best_total_distance = 0
		var best_capital_tiles = null
		for i in 100000:
			if i % 2000 == 0:
				yield()
			
			var try_min_distance = 100000
			var try_total_distance = 0
			var try_capital_tiles = []
			for player in map.game.players:
				var try_tile = find_spawnable(inland_tiles, 20)
				if try_tile:
					for capital_tile in try_capital_tiles:
						var new_distance = map.distance_between(try_tile, capital_tile)
						try_min_distance = min(new_distance, try_min_distance)
						try_total_distance += new_distance
						if try_min_distance < best_min_distance:
							break
					try_capital_tiles.append(try_tile)
				else:
					break
			if (try_min_distance > best_min_distance or (try_min_distance == best_min_distance and try_total_distance > best_total_distance)) and len(try_capital_tiles) == len(map.game.players):
				best_min_distance = try_min_distance
				best_total_distance = try_total_distance
				best_capital_tiles = try_capital_tiles
				#print(str(best_min_distance) + "  " + str(best_total_distance))
		
		yield()
		
		# Picks 4 random capital names from list
		var capital_names = []
		for i in 4:
			var index = randi() % temp_cities.size()
			capital_names.append(temp_cities[index])
			temp_cities.remove(index)
		
		# Picks 10 random city names from list
		var city_names = []
		for i in 12:
			var index = randi() % temp_cities.size()
			city_names.append(temp_cities[index])
			temp_cities.remove(index)
		
		# Picks 10 random port names from list
		var port_names = []
		for i in 5:
			var index = randi() % temp_cities.size()
			port_names.append(temp_cities[index])
			temp_cities.remove(index)
		
		# Adds capital_tiles
		for i in len(map.game.players):
			best_capital_tiles[i].add_capital(map.game.players[i].id, capital_names[i])
		
		# Adds cities
		var city_tiles = []
		for name in city_names:
			var try_tile = find_spawnable(inland_tiles, 10)
			if try_tile:
				try_tile.add_city(name)
				city_tiles.append(try_tile)
		
		# Adds ports
		for name in port_names:
			var try_tile = find_spawnable(coast_tiles, 10)
			if try_tile:
				if !try_tile.city:
					try_tile.add_city(name)
					try_tile.city.make_port()
				else:
					try_tile.city.make_port()
		
		yield()
		
		# Adds forests
	#	for i in range(5):
	#		var try_tile = find_spawnable(tiles, 5)
	#		if try_tile and try_tile.terrain != Util.TERRAIN_WATER and !coast_tiles.has(try_tile):
	#			var forest_instance = forest_object.instance()
	#			map.forestsprites.add_child(forest_instance)
	#			forest_instance.position = try_tile.position
	#			forest_instance.texture = Util.pick_random(forest_tiles)
	#			forest_instance.rotation = rand_range(0, 360)
	
		for i in range(5):
			var try_tile = find_spawnable(tiles, 5)
			var range_length = rand_range(2, 6)
			if try_tile:
				generate_forests(map, try_tile, range_length, 1, coast_tiles)
		
		# Adds fields
		for i in range(7):
			var try_tile = Util.pick_random(city_tiles)
			for j in range(rand_range(0, 5)):
				var neighbours = map.find_neighbours(try_tile)
				var field_tile = Util.pick_random(neighbours)
				if field_tile and field_tile.type != Util.TYPE_FOREST:
					field_tile.set_type(Util.TYPE_FIELD)
					neighbours.erase(field_tile)
			city_tiles.erase(try_tile)
		
		# Adds mountains
		for i in range(5):
			var try_tile = find_spawnable(tiles, 5)
			var range_length = rand_range(2, 6)
			if try_tile and try_tile.type != Util.TYPE_FIELD and try_tile.type != Util.TYPE_FOREST:
				generate_mountains(map, try_tile, range_length, 1)
		
		yield()
		
		if capital_tiles_reachable(map):
			map.setup_tiles_appearance()
			print("MAPGEN: Finished")
			return
		
		print("MAPGEN: Retrying")

static func is_single_tile_island(tile, map) -> bool:
	for neighbour in map.find_neighbours(tile):
		if neighbour.terrain == Util.TERRAIN_GROUND:
			return false
	return true

static func find_spawnable(tiles : Array, max_attempts : int) -> Node:
	for i in max_attempts:
		var try_tile = Util.pick_random(tiles)
		
		if try_tile.terrain == Util.TERRAIN_GROUND and !try_tile.blocked and try_tile.city == null and !city_nearby(try_tile):
			return try_tile
	return null

static func city_nearby(try_tile: Node) -> bool:
	for neighbor_tile in try_tile.find_neighbours():
		if neighbor_tile.city:
			return true
	return false

static func water_nearby(try_tile: Node) -> bool:
	for neighbor_tile in try_tile.find_neighbours():
		if neighbor_tile.terrain == Util.TERRAIN_WATER:
			return true
	return false

static func find_coast(tiles: Array) -> Array:
	var coast_tiles: = []
	for coasttile in tiles:
		if coasttile.terrain == Util.TERRAIN_GROUND and !coasttile.blocked and water_nearby(coasttile):
			coast_tiles.append(coasttile)
	return coast_tiles

static func find_inland(tiles: Array) -> Array:
	var inland_tiles: = []
	for landtile in tiles:
		if landtile.terrain == Util.TERRAIN_GROUND and !landtile.blocked and !water_nearby(landtile):
			inland_tiles.append(landtile)
	return inland_tiles

static func capital_tiles_reachable(map) -> bool:
	var capital_tiles = map.get_capital_tiles()
	if len(capital_tiles) == 0:
		return true
	var starting_capital = capital_tiles[0]
	var reached_capital_tiles = []
	var travelled_tiles = {}
	capital_tiles_reachable_util(map, starting_capital.coord, reached_capital_tiles, travelled_tiles)
	if reached_capital_tiles.size() == map.game.players.size():
		print("MAPGEN: Reached all capital_tiles")
		return true 
	else:
		print("MAPGEN: Failed to reach all capital_tiles")
		return false

static func capital_tiles_reachable_util(map, coord, reached_capital_tiles, travelled_tiles):
	var current_tile = map.get_tile(coord)
	travelled_tiles[current_tile] = true
	if current_tile.city and current_tile.city.is_capital and !reached_capital_tiles.has(current_tile):
		reached_capital_tiles.append(current_tile)
	for i in range (0, 6):
		var next_tile = map.get_tile(current_tile.coord + Util.directions[i])
		if can_enter(current_tile, next_tile) and !travelled_tiles.has(next_tile):
			capital_tiles_reachable_util(map, coord  + Util.directions[i], reached_capital_tiles, travelled_tiles)
	return

static func can_enter(leave_tile, enter_tile) -> bool:
	if enter_tile.blocked:
		return false
	if enter_tile.city != null and enter_tile.city.is_port or leave_tile.city != null and leave_tile.city.is_port:
		return true
	else:
		return enter_tile.terrain == leave_tile.terrain

static func generate_mountains(map, try_tile, range_length : int, index : int):
	if range_length <= index:
		return
	else:
		if !try_tile.type == Util.TYPE_MOUNTAIN:
			try_tile.set_type(Util.TYPE_MOUNTAIN)
		generate_mountains(map, Util.pick_random(map.find_neighbours(try_tile)), range_length, index + 1)

static func generate_forests(map, try_tile, range_length : int, index : int, coast_tiles):
	if range_length <= index:
		return
	else:
		if !try_tile.type == Util.TYPE_FOREST:
			try_tile.set_type(Util.TYPE_FOREST)
			
		for i in range(randi()%4+1):
			var neighbour = Util.pick_random(map.find_neighbours(try_tile))
			if neighbour.city == null and neighbour.type != Util.TYPE_MOUNTAIN and neighbour.type != Util.TYPE_FIELD and !coast_tiles.has(neighbour):
				generate_forests(map, neighbour, range_length, index + 1, coast_tiles)
