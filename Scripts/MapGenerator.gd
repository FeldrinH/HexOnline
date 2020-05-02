const GroundTile = preload("res://Scripts/Tiles/GroundTile.gd")
const WaterTile = preload("res://Scripts/Tiles/WaterTile.gd")

static func generate_map(tile_dict):
	var tiles = tile_dict.values()
	
	var noise = OpenSimplexNoise.new()
	noise.octaves = 2
	noise.period = 700
	randomize()
	noise.seed = randi()
	
	for tile in tiles:
		if noise.get_noise_2dv(tile.position) > 0.3:
			tile.convert_type(WaterTile)
		else:
			tile.convert_type(GroundTile)
			pass
		tile.setup()
