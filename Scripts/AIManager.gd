extends Node
# AI manager
# NB: This only exists on the server

const AI := preload("res://AI.tscn")

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
	
	print("AI Manager: Init completed")

# Event handler called when turn advances to new player. Use to start AI functions
func _on_current_player_changed(active_player: Node):
	yield(get_tree(), "idle_frame") # Small delay to fix some edge cases
	
	for player_id in ai_players:
		var player = world.game.get_player(player_id)
		# print(player.name, player.is_inactive())
		if player.is_inactive() or !player.client.is_ai():
			ai_players[player_id].queue_free()
			ai_players.erase(player_id)
	
	if active_player.client.is_ai():
		if !ai_players.has(active_player.id):
			var ai := AI.instance()
			ai.init_ai(world, active_player)
			add_child(ai)
			ai_players[active_player.id] = ai
		
		ai_players[active_player.id].run_ai()
