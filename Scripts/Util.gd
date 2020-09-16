class_name Util

enum {
	TERRAIN_GROUND
	TERRAIN_WATER
}

enum { 
	TYPE_REGULAR 
	TYPE_FIELD
	TYPE_MOUNTAIN
	TYPE_FOREST
}

const directions = [
	Vector2(-2,  0),
	Vector2(-1, -1),
	Vector2( 1, -1),
	Vector2( 2,  0),
	Vector2( 1,  1),
	Vector2(-1,  1)
]

static func pick_random(array : Array):
	return array[randi() % array.size()]

#static func get_id(obj: Node) -> int:
#	return obj.id if obj else -1

static func create_prefilled_array(size: int, prefill_element) -> Array:
	var array = []
	for i in size:
		array.append(prefill_element)
	return array

static func find_in_dictionary(dict: Dictionary, value):
	for key in dict:
		if dict[key] == value:
			return key
	
	return null
