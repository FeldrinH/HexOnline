extends CanvasLayer

const PlayerSelectButton = preload("res://PlayerSelectButton.tscn")

var world: Node

func _ready():
	for player in world.game.players:
		var button = PlayerSelectButton.instance()
		button.init(world, player)
		$PlayerButtons.add_child(button)
	
	if world.network.is_server:
		$MapGenButton.connect("pressed", self, "_on_mapgen_button_pressed", [], CONNECT_ONESHOT)
		$MapGenButton.visible = true
	else:
		$StartButton.visible = true
	$StartButton.connect("pressed", self, "_on_start_button_pressed", [], CONNECT_ONESHOT)

func _on_mapgen_button_pressed():
	$MapGenButton.disabled = true
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
