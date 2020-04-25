extends Node2D

const max_power = 100

onready var label = $Label
onready var movement_tween = $MovementTween

var tile = null
var power = 0

func init(starting_tile, starting_power):
	set_power(starting_power)
	move_to(starting_tile)

func move_to(target_tile):
	if tile != null:
		tile.army = null
	
	if tile != null:
		#print(position.distance_to(target_tile.position) / 1000)
		movement_tween.interpolate_property(self, "position", position, target_tile.position, max(position.distance_to(target_tile.position) / 1000, 0.25), Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		movement_tween.start()
		yield(movement_tween, "tween_all_completed")
	else:
		position = target_tile.position
	
	tile = target_tile
	if tile.army != null:
		tile.army.merge_with(self)
	else:
		tile.army = self

func merge_with(other_army):
	set_power(power + other_army.power)
	other_army.queue_free()

func set_power(new_power):
	power = new_power
	label.text = str(power)
