extends Node

onready var world: Node2D = $".."

var active: Node = null
var selected: Node = null
var highlighted: Dictionary = {}

func set_active(new_active):
	var previous_active = active
	active = new_active
	if new_active != null:
		new_active.update_highlight_appearance()
	if previous_active != null:
		previous_active.update_highlight_appearance()

func set_selected(new_selected):
	var previous_selected = selected
	selected = new_selected
	if new_selected != null:
		new_selected.update_highlight_appearance()
	if previous_selected != null:
		previous_selected.update_highlight_appearance()

func set_highlighted(tiles : Dictionary):
	var previous_highlighted = highlighted
	highlighted = tiles
	
	for tile in previous_highlighted:
		tile.update_highlight_appearance()
		
	for tile in tiles:
		tile.update_highlight_appearance()

func __active_click(event : InputEvent):
	if event.is_action_pressed("ui_mouse_left"):
		print(world.game.current_player)
		print(world.game.get_our_player())
		print(world.game.is_our_turn())
		print(!world.game.__move_active)
		if world.game.is_our_turn() and !world.game.__move_active:
			if selected == null:
				if active.army != null and world.game.current_player == active.army.player:
					set_selected(active)
					var neighbors = world.find_travelable(active, active.army, 2)
					set_highlighted(neighbors)
			else: # selected != null
				if highlighted.has(active):
					if selected.army != null:
						selected.army.move_to(active)
						set_selected(null)
						set_highlighted({})
				else: # !highlighted.has(active):
					set_selected(null)
					set_highlighted({})
	elif event.is_action_pressed("ui_mouse_debug"):
		world.add_unit(active, 20, world.game.current_player)
	elif event.is_action_pressed("ui_mouse_right"):
		print(world.distance_between(selected, active))
