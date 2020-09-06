extends Node

var world: Node = null

onready var selected_border = $SelectedBorder
onready var hovered_border = $HoveredBorder

var hovered: Node = null
var selected: Node = null
var highlighted: Dictionary = {}

func init(init_world):
	world = init_world
	for tile in world.get_all_tiles():
		tile.connect("input_event", self, "__on_tile_input_event", [tile])
		tile.connect("mouse_entered", self, "__on_tile_mouse_entered", [tile])
		tile.connect("mouse_exited", self, "__on_tile_mouse_exited", [tile])

func set_hovered(new_hovered):
	var previous_hovered = hovered
	hovered = new_hovered
	if new_hovered:
		hovered_border.visible = true
		hovered_border.position = new_hovered.position
	else:
		hovered_border.visible = false

func set_selected(new_selected):
	var previous_selected = selected
	selected = new_selected
	if new_selected:
		selected_border.visible = true
		selected_border.position = new_selected.position
	else:
		selected_border.visible = false

func set_highlighted(tiles : Dictionary):
	var previous_highlighted = highlighted
	highlighted = tiles
	
	for tile in previous_highlighted:
		tile.show_highlight(false)
	for tile in highlighted:
		tile.show_highlight(true)

func __on_tile_mouse_entered(tile: Node2D):
	set_hovered(tile)

func __on_tile_mouse_exited(tile: Node2D):
	if hovered == tile:
		set_hovered(null)

func __on_tile_input_event(_viewport, event: InputEvent, _shape_idx, tile: Node2D):
	if !event.is_action_type() or tile != hovered:
		return
	
	var our_player = world.game.our_player
	if !world.game.is_active_player(our_player):
		return
	
	if event.is_action_pressed("ui_mouse_left"):
		if !world.game.is_move_active():
			if !selected:
				if hovered.army and world.game.is_move_allowed(Network.our_id, hovered.army.player):
					set_selected(hovered)
					set_highlighted(world.find_travelable(hovered, hovered.army, world.game.MOVE_RANGE))
			else: # selected != null
				if highlighted.has(hovered):
					if selected.army:
						selected.army.rpc("move_to", hovered.coord)
						set_selected(null)
						set_highlighted({})
				else: # !highlighted.has(hovered):
					set_selected(null)
					set_highlighted({})
	elif event.is_action_pressed("ui_mouse_debug"):
		if our_player:
			world.rpc("add_unit", hovered.coord, 20, our_player.id, false)
	#elif event.is_action_pressed("ui_mouse_right"):
		#print(world.distance_between(selected, hovered))
