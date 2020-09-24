extends Node

var __shared: Dictionary = {
	"profile": { 
		"display_name": OS.get_environment("USERNAME") + " " + str(OS.get_process_id()) 
	},
	"ip": "localhost"
}

func set_shared(identifier: String, new_value):
	__shared[identifier] = new_value

func get_shared(identifier: String):
	return __shared.get(identifier)
