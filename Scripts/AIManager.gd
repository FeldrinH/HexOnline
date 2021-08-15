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
	
	for player in world.game.players:
		if player.client.is_ai():
			var ai := AI.instance()
			ai.init(world, player)
			add_child(ai)
			ai_players[player.id] = ai
	
	print("AI Manager: Init completed")

# Event handler called when turn advances to new player. Use to start AI functions
func _on_current_player_changed(new_player: Node):
	yield(get_tree(), "idle_frame") # Small delay to fix some edge cases
	if new_player.client.is_ai() and ai_players.has(new_player.id):
		ai_players[new_player.id].run_ai()
