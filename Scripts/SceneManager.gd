extends Node

var __shared: Dictionary = {}

func set_shared(identifier: String, new_value):
	__shared[identifier] = new_value

func get_shared(identifier: String, default_value):
	return __shared.get(identifier, default_value)
