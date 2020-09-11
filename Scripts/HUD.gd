extends CanvasLayer

var world: Node

onready var timer_label = $Root/TimerLabel

func init(init_world):
	world = init_world
	world.network.our_client.connect("player_changed", self, "__on_our_client_player_changed")
	world.game.connect("active_player_changed", self, "__on_active_player_changed")
	world.game.connect("moves_remaining_changed", self, "__on_moves_remaining_changed")

func _process(delta):
	timer_label.text = str(ceil(world.game.timer.time_left))

func __on_our_client_player_changed(player: Node):
	if player:
		$Root/OurLabel.text = player.name
		$Root/OurLabel.modulate = player.unit_color
	else:
		$Root/OurLabel.text = "None"
		$Root/OurLabel.modulate = Color.white

func __on_active_player_changed(player: Node):
	if player:
		$Root/TurnLabel.text = player.name
		$Root/TurnLabel.modulate = player.unit_color
		$Root/MoveLabel.modulate = player.unit_color
	else:
		$Root/TurnLabel.text = "None"
		$Root/TurnLabel.modulate = Color.white
		$Root/MoveLabel.modulate = Color.white

func __on_moves_remaining_changed(moves_remaining: int):
	$Root/MoveLabel.text = str(moves_remaining)
