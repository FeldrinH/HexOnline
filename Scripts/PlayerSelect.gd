extends OptionButton

var world: Node = null

func init(init_world):
	world = init_world
	
	add_item("None")
	for player in world.game.players:
		add_item(player.name)
	
	connect("item_selected", self, "__selected")

func refresh():
	if world.network.our_client and world.network.our_client.player:
		select(world.network.our_client.player.id + 1)
	else:
		select(0)

func __selected(index: int):
	if world.network.our_client:
		if index > 0:
			world.network.our_client.rpc("set_player_id", index - 1)
			print("Selected player: " + world.network.our_client.player.name)
		else:
			world.network.our_client.rpc("set_player_id", null)
			print("Deselected player")
	else:
		select(0)
		print("ERROR: No client, start or join server first")
