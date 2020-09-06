extends CanvasLayer

var world: Node

func init(init_world):
	world = init_world
	world.network.our_client.connect("player_changed", self, "__on_player_changed")

func __on_player_changed(new_player: Node):
	$Root/Label.text = new_player.name
	$Root/Label.modulate = new_player.unit_color
