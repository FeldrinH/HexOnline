extends CanvasLayer

var world: Node

func init(init_world):
	world = init_world
	world.game.connect("player_selected", self, "__on_player_selected")

func __on_player_selected(client_id: int, player: Node):
	if client_id == Network.our_id:
		$Root/Label.text = player.name
		$Root/Label.modulate = player.unit_color
