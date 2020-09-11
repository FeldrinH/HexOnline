extends CanvasLayer

var world: Node

onready var timer_text = $Root/TimerText

func init(init_world):
	world = init_world
	world.network.our_client.connect("player_changed", self, "__on_player_selected")

func __on_player_selected(player: Node):
	if player:
		$Root/Label.text = player.name
		$Root/Label.modulate = player.unit_color
	else:
		$Root/Label.text = "None"
		$Root/Label.modulate = Color.white

func set_timer_text(time):
	timer_text.text = String(time)
