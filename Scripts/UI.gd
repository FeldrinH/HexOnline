extends Node

onready var world: Node = $".."
const elements: Dictionary = {}

func _enter_tree():
	for child in get_children():
		elements[child.name] = child
		remove_child(child)

func show(element_name: String):
	var element = elements[element_name]
	add_child(element)
	element.init(world)

func hide(element_name: String):
	remove_child(elements[element_name])
