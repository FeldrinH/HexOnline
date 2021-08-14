extends Reference

var astar := preload("res://Scripts/HexAStar.gd").new()

var world: Node2D
var player: Node

func _init(world: Node2D, player: Node):
	self.world = world
	self.player = player

# Called every time it is this AI players turn, to run AI for this player
func run_ai():
	print(player.client.profile.display_name + ": Executing turn")
	
	var enemy_capital_tile
	for i in world.get_capitals():
		if i.city.player != player:
			enemy_capital_tile = i
			break
	
	update_astar_map()
	var player_units = world.get_player_units(player)
	for unit in player_units:
		var shortest_path = find_shortest_path(unit.tile, enemy_capital_tile)
		print(shortest_path)
		for tile in shortest_path:
			tile.debug_label.text = str(unit.name)
			tile.debug_label.visible = true

		if len(shortest_path) > 1:
			unit.rpc("move_to", shortest_path[1].coord)

	world.game.rpc("skip_turn", player.id)

func update_astar_map():
	astar.clear()
	
	var tiles = world.get_all_tiles()
	for tile in tiles:
		var weight = 1 if tile.city else 2
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
