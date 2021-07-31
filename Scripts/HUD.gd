extends CanvasLayer

var world: Node

onready var timer_label = $Turn/TimerLabel

func _ready():
	world.network.our_client.connect("player_changed", self, "__on_our_client_player_changed")
	world.game.connect("current_player_changed", self, "__on_current_player_changed")
	world.game.connect("moves_remaining_changed", self, "__on_moves_remaining_changed")
	__on_our_client_player_changed(world.network.get_our_player())
	__on_current_player_changed(world.game.current_player)
	__on_moves_remaining_changed(world.game.moves_remaining)

func _process(delta):
	timer_label.text = str(ceil(world.game.timer.time_left))

func __on_our_client_player_changed(player: Node):
	if player:
		$Shared/OurLabel.text = player.name
		$Shared/OurLabel.set("custom_colors/font_outline_modulate", player.unit_color)
	else:
		$Shared/OurLabel.text = ""

func __on_current_player_changed(player: Node):
	if player:
		$Turn/TurnLabel.text = player.name
		$Turn/TurnLabel.set("custom_colors/font_outline_modulate", player.unit_color)
		$Turn/MoveLabel.set("custom_colors/font_outline_modulate", player.unit_color)
		$Turn.visible = true
	else:
		$Turn.visible = false

func __on_moves_remaining_changed(moves_remaining: int):
	$Turn/MoveLabel.text = str(moves_remaining)

func toggle_main_menu():
	world.ui.show("MainMenu")

func skip_turn():
	world.game.rpc("skip_turn", world.network.get_our_player().id)
