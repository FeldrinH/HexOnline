extends Node

onready var world: Node = $".."
const __elements: Dictionary = {}

func _enter_tree():
	for child in get_children():
		__elements[child.name] = child
		remove_child(child)

func show(element_name: String):
	var element = __elements[element_name]
	if !element.is_inside_tree():
		element.world = world
		add_child(element)

func hide(element_name: String):
	var element: Node = __elements[element_name]
	if element.is_inside_tree():
		remove_child(element)
