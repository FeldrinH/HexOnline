extends Node2D

const max_power = 100

var tile = null
var power = 0

func init(starting_tile, starting_power):
	set_power(starting_power)
	move_to(starting_tile)

func move_to(target_tile):
	if tile != null:
		tile.army = null
	 
	$Tween.interpolate_property(self, "position", self.position, target_tile.position, 2)
	$Tween.start()
	
	tile = target_tile
	tile.army = self

func set_power(new_power):
	power = new_power
