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
	
	world.game.connect("current_player_changed", self, "_on_current_player_changed")
	
	pass # TODO: Setup objects for each AI client
	
	print("AI Manager: Init completed")

# Event handler called when turn advances to new player. Use to start AI functions
func _on_current_player_changed(new_player: Node):
	print("AI Manager: New turn")
	pass # TODO: If new player has AI client, run the AI stuff
	
