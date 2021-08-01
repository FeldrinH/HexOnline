extends AStar2D



func _compute_cost(u, v):
		return 1

func _estimate_cost(u, v):
	return Util.distance_between(u, v) / 2

