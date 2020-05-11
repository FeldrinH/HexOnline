

static func generate_map(manager):
	var tiles = manager.get_all_tiles()
	
	randomize()
	
	for tile in tiles:
		tile.set_terrain(Util.TERRAIN_GROUND)
	
	var seatiles = [manager.get_tile(Vector2(15, 1))]
	
	while seatiles.size() < 60:
		var expand_at = Util.pick_random(seatiles)
		var neighbor = Util.pick_random(manager.find_in_radius(expand_at, 1).keys())
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
	
	for player in manager.players:
		while true:
			var try_tile = Util.pick_random(tiles)
			if try_tile.terrain == Util.TERRAIN_GROUND and !try_tile.blocked:
				try_tile.add_capital(player)
				break
