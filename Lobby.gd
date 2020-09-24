extends CanvasLayer

const PlayerSelectButton = preload("res://PlayerSelectButton.tscn")

var world: Node

func init(init_world):
	world = init_world
	for player in world.game.players:
		var button = PlayerSelectButton.instance()
		button.init(world, player)
		$PlayerButtons.add_child(button)
	
	$CloseButton.connect("pressed", self, "_on_close_button_pressed")

func _on_close_button_pressed():
	world.ui.hide(name)
