extends CanvasLayer

var world: Node

onready var timer_label = $Turn/TimerLabel

func init(init_world):
	world = init_world
	world.network.our_client.connect("player_changed", self, "__on_our_client_player_changed")
	world.game.connect("turn_changed", self, "__on_turn_changed")
	world.game.connect("moves_remaining_changed", self, "__on_moves_remaining_changed")
	__on_our_client_player_changed(world.network.get_our_player())
	__on_turn_changed(world.game.current_player)
	__on_moves_remaining_changed(world.game.moves_remaining)

func _process(delta):
	timer_label.text = str(ceil(world.game.timer.time_left))

func __on_our_client_player_changed(player: Node):
	if player:
		$Shared/OurLabel.text = player.name
		$Shared/OurLabel.modulate = player.unit_color
	else:
		$Shared/OurLabel.text = "None"
		$Shared/OurLabel.modulate = Color.white

func __on_turn_changed(player: Node):
	if player:
		$Turn/TurnLabel.text = player.name
		$Turn/TurnLabel.modulate = player.unit_color
		$Turn/MoveLabel.modulate = player.unit_color
		$Turn.visible = true
	else:
		$Turn.visible = false

func __on_moves_remaining_changed(moves_remaining: int):
	$Turn/MoveLabel.text = str(moves_remaining)
