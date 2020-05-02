class_name Util

enum {
	TERRAIN_GROUND
	TERRAIN_WATER
}

const directions = [
	Vector2( 2,  0), 
	Vector2( 1,  1),
	Vector2(-1,  1),
	Vector2(-2,  0),
	Vector2(-1, -1),
	Vector2( 1, -1)
]

static func pick_random(array : Array):
	return array[randi() % array.size()]
