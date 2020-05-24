extends Node2D

var army_unit = load("res://ArmyUnit.tscn")

onready var label = $Label
onready var movement_tween = $MovementTween

const max_power = 100

var manager = null

var player = null
var tile = null
var power : int = 0

var on_ship : bool = false

func init(unit_manager, starting_tile, starting_power, unit_player):	
	init_detached(unit_manager, starting_tile, starting_power, unit_player)
	arrive_at_tile(starting_tile)

func init_detached(unit_manager, starting_tile, starting_power, unit_player):
	manager = unit_manager
	player = unit_player
	$Sprites.modulate = unit_player.unit_color
	set_power(starting_power)
	position = starting_tile.position

func move_to(target_tile):
	manager.turn_active = true
	
	if target_tile.terrain == Util.TERRAIN_WATER:
		on_ship = true
		update_appearance()
		
	if target_tile.city != null and target_tile.city.is_port:
		on_ship = false
		update_appearance()
	
	# If combined army would exeed max power, send detachment and stay in current tile
	if target_tile.army != null and target_tile.army.player == player and power + target_tile.army.power > max_power:
		var split_power = max_power - target_tile.army.power
		if split_power > 0:
			var split_unit = split(split_power)
			split_unit.move_to(target_tile)
		manager.turn_active = false
		return
	
	if target_tile.terrain == Util.TERRAIN_GROUND:
		manager.effects.play_movement_effects()
	elif target_tile.terrain == Util.TERRAIN_WATER:
		manager.effects.play_ship_sound()

	arrive_at_tile(null)
	
	movement_tween.interpolate_property(self, "position", position, target_tile.position, max(position.distance_to(target_tile.position) / 1000, 0.25), Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	movement_tween.start()
	yield(movement_tween, "tween_all_completed")
	arrive_at_tile(target_tile)
	
	manager.turn_active = false
	
func arrive_at_tile(target_tile):
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
		if target_tile.army == self:
			enter_tile(target_tile)
	tile = target_tile

func enter_tile(target_tile):
	target_tile.set_player(player)
	for adjacent_tile in manager.find_travelable(target_tile, self, 1):
		if adjacent_tile.army == null:
			adjacent_tile.set_player(player)

func battle(defending_army) -> bool:
	manager.effects.play_battle_effects(position)
	
	var defending_power = defending_army.power * 2
	var we_won = randf() < 0.5 if power == defending_power else power > defending_power
	
	if we_won:
		__apply_loss(self, defending_army)
		defending_army.queue_free()
	else:
		__apply_loss(defending_army, self)
		self.queue_free()
	
	return we_won

static func __apply_loss(winning_army, losing_army):
	winning_army.set_power(max(winning_army.power - round(losing_army.power * rand_range(0.75, 1)), 1))

func merge_with(other_army):
	set_power(power + other_army.power)
	other_army.queue_free()

func split(split_power):
	set_power(power - split_power)
	
	return manager.add_unit_detached(tile, split_power, player)

func set_power(new_power):
	power = new_power
	update_appearance()
	
func update_appearance():
	label.text = str(power)
	
	for sprite in $Sprites.get_children():
		sprite.visible = false
	
	if !on_ship:
		if power < 40:
			$Sprites/SpriteInfantry.visible = true
		elif power < 70:
			$Sprites/SpriteCavalry.visible = true
		else:
			$Sprites/SpriteArtillery.visible = true
	else:
		$Sprites/SpriteIronclad.visible = true
