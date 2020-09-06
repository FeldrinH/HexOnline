extends OptionButton

var world: Node = null

func init(init_world):
	world = init_world
	
	add_item("None")
	for player in world.game.players:
		add_item(player.name)
	
	connect("item_selected", self, "__selected")

func refresh():
	if world.game.our_player:
		select(world.game.our_player.id + 1)
	else:
		select(0)

func __selected(index: int):
	if Network.our_id != -1:
		if index > 0:
			world.game.rpc("request_select_player", index - 1)
		else:
			world.game.rpc("request_select_player", -1)
	else:
		select(0)
		print("ERROR: No client, start or join server first")
