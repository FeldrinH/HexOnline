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

func _pressed():
	if player.client == world.network.our_client:
		world.network.select_player(-1)
	elif player.client == null:
		world.network.select_player(player.id)

func _on_client_changed(new_client: Node):
	update_appearance()
	
