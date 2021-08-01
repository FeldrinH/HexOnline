extends Node
# AI manager
# NB: This only exists on the server

onready var world: Node2D = $".."

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
		var enemy_capital
		for i in world.get_capitals():
			if i.city.player != new_player:
				enemy_capital = i
				break
				
		for unit in world.get_player_units(new_player):
			var shortest_path = find_shortest_path(unit.tile, enemy_capital, unit)
			print(shortest_path)
			for tile in shortest_path:
				tile.debug_label.text = str(unit.name)
				tile.debug_label.visible = true
			
func find_shortest_path(start, target, army) -> Array:
	var path = []
	return find_shortest_path_util(start, target, army, path)
	
func find_shortest_path_util(current_tile, target, army, path) -> Array:
	var next_dist = world.distance_between(current_tile, target)
	var next_tile = current_tile

	if next_dist > 0:
		for i in world.find_travelable(current_tile, army, 2):
			var dist = world.distance_between(i, target)
			if next_dist > dist:
				next_tile = i 
				next_dist = dist
		path.append(next_tile)
		return find_shortest_path_util(next_tile, target, army, path)
	else:
		return path
