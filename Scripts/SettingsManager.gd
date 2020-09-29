extends Node

const log10 = log(10)

var __shared: Dictionary = {
	"profile": { 
		"display_name": OS.get_environment("USERNAME") + " " + str(OS.get_process_id()) 
	},
	"ip": "localhost",
	"volume": 1.0
}

func _enter_tree():
	var f = File.new()
	if f.open("user_settings.json", File.READ) == OK:
		var parse = JSON.parse(f.get_as_text())
		if !parse.error and typeof(parse.result) == TYPE_DICTIONARY:
			__shared = parse.result
			print("INFO: Read user settings from file")
		else:
			print("WARNING: Malformed settings file, falling back to defaults")
	else:
		print("INFO: No settings file, falling back to defaults")
	f.close()
	
	apply_volume()

func _exit_tree():
	var f = File.new()
	if f.open("user_settings.json", File.WRITE) == OK:
		f.store_string(JSON.print(__shared))
		print("INFO: Written user settings to file")
	else:
		print("ERROR: Failed to write to settings file")
	f.close()

func apply_volume(new_volume=null):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), log(get_shared("volume")) / log10 * 20)

func set_shared(identifier: String, new_value):
	__shared[identifier] = new_value

func get_shared(identifier: String):
	return __shared.get(identifier)
