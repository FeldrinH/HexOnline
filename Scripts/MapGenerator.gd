extends Object

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

static func generate_map(tilemap):
	var noise = OpenSimplexNoise.new()
	noise.octaves = 2
	noise.period = 700
	randomize()
	noise.seed = randi()
	
	for coord in tilemap.get_used_cells():
		if noise.get_noise_2dv(tilemap.map_to_world(coord)) > 0.3:
			tilemap.set_cellv(coord, -1)

