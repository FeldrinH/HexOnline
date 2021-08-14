extends Node
# AI manager
# NB: This only exists on the server

const AI := preload("res://Scripts/AI.gd")

onready var world: Node2D = $".."

const ai_players := {}

func _ready():
	var game := $"../Game"
	game.connect("pre_game_start", self, "_on_pre_game_start")

func _on_pre_game_start():
	if !world.network.is_server:
		queue_free() # If not on server, remove this
		return
	
	world.game.connect("current_player_changed", self, "_on_current_player_changed", [], CONNECT_DEFERRED)
	
	for player in world.game.players:
		if player.client.is_ai():
			ai_players[player.id] = AI.new(world, player)
	
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
			var shortest_path = find_shortest_path(unit.tile, enemy_capital_tile, new_player)
			print(shortest_path)
			for tile in shortest_path:
				tile.debug_label.text = str(unit.name)
				tile.debug_label.visible = true
			
			if len(shortest_path) > 0:
				unit.rpc("move_to", shortest_path[1].coord)
		
		world.game.rpc("skip_turn", new_player.id)
			
func find_shortest_path(start, target, player) -> Array:
	astar.load_map(world, player)
	var tile_path = []
	var path = astar.get_id_path(start.id, target.id)
	for i in path:
		tile_path.append(world.get_tile_by_id(i))
	return tile_path

func assign_weight(unit_tile, player):
	for tile in world.find_travelable(unit_tile, player, 2):
		if tile.army and tile.player != player:
			return Util.distance_between(unit_tile.coord, tile.coord)/2 * 0.5
		elif tile.city:
			return 0.5
	return 1


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
	if ai_players.has(new_player.id):
		ai_players[new_player.id].run_ai()
