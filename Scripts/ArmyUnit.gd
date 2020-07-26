extends Node2D

var army_unit = load("res://ArmyUnit.tscn")

onready var label = $Label
onready var movement_tween = $MovementTween

const max_power = 100

var world = null

var player = null
var tile = null
var power : int = 0

var on_ship : bool = false

func init(unit_world, starting_tile, starting_power, unit_player, silent: bool):
	init_detached(unit_world, starting_tile, starting_power, unit_player, silent)
	do_enter_tile(starting_tile, !silent)

func init_detached(unit_world, starting_tile, starting_power, unit_player, silent: bool):
	world = unit_world
	player = unit_player
	$Sprites.modulate = unit_player.unit_color
	position = starting_tile.position
	set_power(starting_power, !silent)

remotesync func move_to(target_tile_coord):
	world.game.await_start_move()
	if world.game.is_rpc_sender_move_allowed(player):
		execute_move_to(world.get_tile(target_tile_coord))
		world.game.advance_move(1)
	world.game.end_move()

func execute_move_to(target_tile):
	if target_tile.terrain == Util.TERRAIN_WATER:
		on_ship = true
		update_appearance()
		
	if target_tile.city != null and target_tile.city.is_port:
		on_ship = false
		update_appearance()
	
	# If combined army would exeed max power, send detachment and stay in current tile
	if target_tile.army and target_tile.army.player == player and power + target_tile.army.power > max_power:
		var split_power = max_power - target_tile.army.power
		if split_power > 0:
			var split_unit = split(split_power)
			split_unit.execute_move_to(target_tile)
		return
	
	if target_tile.terrain == Util.TERRAIN_GROUND:
		world.effects.play_movement_effects()
	elif target_tile.terrain == Util.TERRAIN_WATER:
		world.effects.play_ship_sound()

	do_enter_tile(null, true)
	
	movement_tween.interpolate_property(self, "position", position, target_tile.position, max(position.distance_to(target_tile.position) / 1000, 0.25), Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	movement_tween.start()
	yield(movement_tween, "tween_all_completed")
	
	do_enter_tile(target_tile, true)

func do_enter_tile(target_tile, do_enter_event: bool):
	var has_entered = false
	
	if target_tile == null:
		if tile != null:
			tile.army = null
	else:
		if target_tile.army != null:
			if target_tile.army.player != player:
				if battle(target_tile.army):
					target_tile.army = self
					has_entered = true
			else:
				target_tile.army.merge_with(self)
				has_entered = true
		else:
			target_tile.army = self
			has_entered = true
		
	tile = target_tile
	if has_entered and do_enter_event:
		on_enter_tile(target_tile)

func on_enter_tile(target_tile):
	target_tile.set_player(player.id)
	for adjacent_tile in world.find_travelable(target_tile, self, 1):
		if adjacent_tile.army == null:
			adjacent_tile.set_player(player.id)

func battle(defending_army) -> bool:
	world.effects.play_battle_effects(position)
	
	var defending_power = defending_army.power
	if defending_army.tile.city:
		defending_power *= 2
	
	var we_won = world.network.rng.randf() < 0.5 if power == defending_power else power > defending_power
	
	if we_won:
		__apply_loss(self, defending_army)
		defending_army.queue_free()
	else:
		__apply_loss(defending_army, self)
		self.queue_free()
	
	return we_won

func __apply_loss(winning_army, losing_army):
	winning_army.set_power(max(winning_army.power - round(losing_army.power * world.network.rng.randf_range(0.75, 1)), 1))

func add_forces():
	if power + 10 < max_power:
		power += 10
	else:
		power = max_power

func merge_with(other_army):
	set_power(power + other_army.power)
	other_army.queue_free()

func split(split_power):
	set_power(power - split_power)
	return world.add_unit_detached(tile.coord, split_power, player.id, true)

func can_enter(leave_tile, enter_tile) -> bool:
	if enter_tile.blocked:
		return false
	
	if leave_tile == tile:
		if enter_tile.city != null and enter_tile.city.is_port or leave_tile.city != null and leave_tile.city.is_port:
			return true
		else:
			return enter_tile.terrain == leave_tile.terrain
	else:
		return leave_tile.terrain == tile.terrain and enter_tile.terrain == leave_tile.terrain

func set_power(new_power, show_popup: bool = true):
	if show_popup:
		world.effects.play_number_popup(new_power - power, player.unit_color, position)
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
