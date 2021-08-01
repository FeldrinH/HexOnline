extends TextureButton

var world: Node
var player: Node

func init(button_world, button_player):
	world = button_world
	player = button_player
	
	update_appearance()
	player.connect("client_changed", self, "_on_client_changed")

func update_appearance():
	match player.client:
		null:
			$Label.text = player.name
			$Panel.modulate = player.unit_color
		world.network.our_client:
			$Label.text = "* " + player.name + " (" + player.client.profile.display_name + ") *"
			$Panel.modulate = player.unit_color.lightened(0.2)
		_:
			$Label.text = player.name + " (" + player.client.profile.display_name + ")"
			$Panel.modulate = player.unit_color.darkened(0.2)

func _gui_input(event: InputEvent):
	if event.is_action_pressed("ui_mouse_left"):
		do_select()
	elif event.is_action_pressed("ui_mouse_right") and world.network.is_server:
		do_ai_select()

func do_select():
	if player.client == world.network.our_client:
		world.network.select_player(-1)
	elif !player.client or player.client.is_ai():
		world.network.select_player(player.id)

func do_ai_select():
	if player.client and player.client.is_ai():
		world.network.select_player_for_client(player.client.id, -1)
	elif !player.client:
		var client_id = world.network.create_ai_client_for_player(player.id, {
			"display_name": "[AI] " + player.name
		})
		world.network.select_player_for_client(client_id, player.id)

func _on_client_changed(new_client: Node):
	update_appearance()
	
