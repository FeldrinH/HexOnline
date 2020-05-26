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
	
	for player in map.players:
		while true:
			var try_tile = Util.pick_random(tiles)
			var nearby_tiles = map.find_in_radius(try_tile, 6)
			#check_for_capital(nearby_tiles)
			if !nearby_tiles.has(try_tile):
				if try_tile.terrain == Util.TERRAIN_GROUND and !try_tile.blocked:
					try_tile.add_capital(player)
					break
			
	var file = File.new()
	file.open("res://Scripts/city_names.csv", file.READ)
	
	var temp_cities = []
	
	while !file.eof_reached():
		temp_cities.append(file.get_line())
	file.close()
	
	for i in range(10):
		var index = randi() % temp_cities.size()
		city_names.append(temp_cities[index])
		temp_cities.remove(index)
		
	for name in city_names:
		for i in range (10):
			var try_tile = find_spawnable(tiles, name)
			if try_tile != null:
				try_tile.add_city(name)
				break
	# Adds ports
	for port_name in port_names:
		var try_tile = find_spawnable(find_coast(map, seatiles), port_name)
		if try_tile != null:
			try_tile.add_city(port_name)
			try_tile.city.make_port()
						
static func find_spawnable(tiles, name) -> Node:
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
