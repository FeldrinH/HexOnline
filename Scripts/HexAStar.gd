extends AStar2D

func _compute_cost(u, v):
		return 1

func _estimate_cost(u : int, v : int):
	return Util.distance_between(get_point_position(u), get_point_position(v)) / 2
