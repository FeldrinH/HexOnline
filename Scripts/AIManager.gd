extends Node
# AI manager
# NB: This only exists on the server

onready var world: Node2D = $".."
onready var astar := preload("res://Scripts/HexAStar.gd").new()

func _ready():
	var game := $"../Game"
	game.connect("pre_game_start", self, "_on_pre_game_start")
	
func _on_pre_game_start():
	if !world.network.is_server:
		queue_free() # If not on server, remove this
		return
	
	world.game.connect("current_player_changed", self, "_on_current_player_changed", [], CONNECT_DEFERRED)
	
	pass # TODO: Setup objects for each AI client
	
	print("AI Manager: Init completed")

# Event handler called when turn advances to new player. Use to start AI functions
func _on_current_player_changed(new_player: Node):
	 # TODO: If new player has AI client, run the AI stuff
	if new_player.client.is_ai():
		print("AI Manager: New turn")
		var enemy_capital_tile
		for i in world.get_capitals():
			if i.city.player != new_player:
				enemy_capital_tile = i
				break
		
		var player_units = world.get_player_units(new_player)
		for unit in player_units:
			var shortest_path = find_shortest_path(unit.tile, enemy_capital_tile, unit)
			print(shortest_path)
			for tile in shortest_path:
				tile.debug_label.text = str(unit.name)
				tile.debug_label.visible = true
			if unit.tile != enemy_capital_tile:
				unit.rpc("move_to", shortest_path[1].coord)
			if unit == player_units[-1]:
				print("end of turn")
				if world.network.is_server:
					world.game.call_advance_turn()
			
func find_shortest_path(start, target, army) -> Array:
	astar.load_map(world, army)
	var tile_path = []
	var path = astar.get_id_path(start.id, target.id)
	for i in path:
		tile_path.append(world.get_tile_by_id(i))
	return tile_path
		
#func find_shortest_path_util(current_tile, target, army, path) -> Array:
#	var next_dist = world.distance_between(current_tile, target)
#	var next_tile = current_tile
#
#	if next_dist > 0:
#		for i in world.find_travelable(current_tile, army, 2):
#			var dist = world.distance_between(i, target)
#			if next_dist > dist:
#				next_tile = i 
#				next_dist = dist
#		path.append(next_tile)
#		return find_shortest_path_util(next_tile, target, army, path)
#	else:
#		return path
