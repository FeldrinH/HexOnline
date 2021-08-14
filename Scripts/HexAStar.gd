extends AStar2D

func load_map(world, player):
	clear()
	var tiles = world.get_all_tiles()
	for tile in tiles:
		var weight = 1 if tile.city else 2
		add_point(tile.id, tile.coord, weight)
	for tile in tiles:
		
		for travelable in world.find_travelable(tile, player, 2):
			 connect_points(tile.id, travelable.id)

func _compute_cost(u, v):
		return 1

func _estimate_cost(u : int, v : int):
	return Util.distance_between(get_point_position(u), get_point_position(v)) / 2
