static func send_map(world, target_id: int):
	var tiles: Array = world.get_all_tiles()
	
	for tile in tiles:
		tile.rpc_id(target_id, "set_terrain", tile.terrain)
		
		if tile.player:
			tile.rpc_id(target_id, "set_player", tile.player.id)
			
		if tile.city:
			if tile.city.is_capital:
				tile.rpc_id(target_id, "add_capital", tile.city.player.id)
			else:
				tile.rpc_id(target_id, "add_city", tile.city.city_name)
				if tile.city.is_port:
					tile.city.rpc_id(target_id, "make_port")
	for tile in tiles:
		tile.rpc_id(target_id, "setup_appearance")
	
	for unit in world.units.get_children():
		world.rpc_id(target_id, "add_unit", unit.tile.coord, unit.power, unit.player.id, unit.name)
