extends OptionButton

onready var world: Node = get_node("/root/Root/World")

func _ready():
	add_item("None")
	for player in world.game.players:
		add_item(player.name)
	
	connect("item_selected", self, "__selected")

func refresh():
	var cur_player = world.game.get_our_player() 
	if cur_player:
		select(cur_player.id + 1)
	else:
		select(0)

func __selected(index: int):
	if world.network.our_client:
		if index > 0:
			world.network.our_client.rpc("select_player", index - 1)
			print("Selected player: " + world.game.get_our_player().name)
		else:
			world.network.our_client.rpc("select_player", null)
			print("Deselected player")
	else:
		select(0)
		print("ERROR: No client, start or join server first")
