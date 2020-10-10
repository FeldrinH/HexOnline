extends CanvasLayer

const PlayerSelectButton = preload("res://PlayerSelectButton.tscn")

var world: Node

func _ready():
	setup_player_buttons()
	world.game.connect("players_changed", self, "setup_player_buttons")
	
	if world.network.is_server:
		$MapGenButton.connect("pressed", self, "_on_mapgen_button_pressed", [], CONNECT_ONESHOT)
		$MapGenButton.visible = true
	else:
		$StartButton.visible = true
	$StartButton.connect("pressed", self, "_on_start_button_pressed", [], CONNECT_ONESHOT)

func setup_player_buttons():
	for child in $PlayerButtons.get_children():
		$PlayerButtons.remove_child(child)
	for player in world.game.players:
		var button = PlayerSelectButton.instance()
		button.init(world, player)
		$PlayerButtons.add_child(button)

func _on_mapgen_button_pressed():
	if world.game.get_selected_players_count() < 2:
		return
	
	$MapGenButton.disabled = true
	world.game.remove_unselected_players()
	yield(world.generate_map(), "completed")
	world.send_map(0)
	$MapGenButton.visible = false
	$StartButton.visible = true

func _on_start_button_pressed():
	if world.network.is_server:
		world.game.rpc("start_game")
	world.ui.hide(name)
	world.ui.show("Overlay")
	world.ui.show("DebugMenu")
