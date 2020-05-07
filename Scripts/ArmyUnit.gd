extends Node2D

const max_power = 100

onready var army_unit = load("res://ArmyUnit.tscn")

onready var army_manager = $".."
onready var map_manager = $"../../HexGrid"

onready var label = $Label
onready var movement_tween = $MovementTween
onready var audio_player = $AudioStreamPlayer
onready var battle_particles : Particles2D = $Particles2D

var marching_clip = load("res://Sounds/march.ogg")

var player
var tile = null
var power : int = 0

func init(starting_tile, starting_power, side):	
	init_detached(starting_tile, starting_power, side)
	enter_tile(starting_tile)

func init_detached(starting_tile, starting_power, side):
	player = side
	$Sprite.modulate = side.unit_color
	set_power(starting_power)
	position = starting_tile.position

func move_to(target_tile):
	map_manager.turn_active = true
	
	audio_player.stream = marching_clip
	audio_player.play()
	
	# If combined army would exeed max power, send detachment and stay in current tile
	if target_tile.army != null and power + target_tile.army.power > max_power:
		var split_unit = split(max_power - target_tile.army.power)
		split_unit.move_to(target_tile)
		map_manager.turn_active = false
		return
	
	enter_tile(null)
	
	movement_tween.interpolate_property(self, "position", position, target_tile.position, max(position.distance_to(target_tile.position) / 1000, 0.25), Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	movement_tween.start()
	yield(movement_tween, "tween_all_completed")
	enter_tile(target_tile)
	
	#audio_player.stop()
	
	map_manager.turn_active = false

func enter_tile(target_tile):
	if target_tile == null:
		if tile != null:
			tile.army = null
	else:
		if target_tile.army != null:
			if target_tile.army.player != player:
				if battle(target_tile.army):
					target_tile.army = self
			else:
				target_tile.army.merge_with(self)
		else:
			target_tile.army = self
	
	tile = target_tile

func battle(defending_army) -> bool:
	battle_particles.emitting = true
	var we_won = randf() < 0.5 if power == defending_army.power else power > defending_army.power
	
	if we_won:
		__handle_loss(self, defending_army)
		defending_army.queue_free()
	else:
		__handle_loss(defending_army, self)
		self.queue_free()
	
	return we_won

static func __handle_loss(winning_army, losing_army):
	winning_army.set_power(max(winning_army.power - round(losing_army.power * rand_range(0.75, 1)), 1))

func merge_with(other_army):
	set_power(power + other_army.power)
	other_army.queue_free()

func split(split_power):
	set_power(power - split_power)
	
	var unit_instance = army_unit.instance()
	army_manager.add_child(unit_instance)
	unit_instance.init_detached(tile, split_power, player)
	
	return unit_instance

func set_power(new_power):
	power = new_power
	label.text = str(power)
