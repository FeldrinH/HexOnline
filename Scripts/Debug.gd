extends Node

# Debug helper

onready var debug = $"/root/Root/DebugMenu"
onready var world = $".."

func _ready():
	$"/root".connect("ready", self, "autosetup")

# Run after scene tree has initialized
func autosetup():
	if OS.has_feature("editor"):
		autosetup_in_editor()

# Run on autosetup when started from editor
func autosetup_in_editor():
	pass
	#debug.get_node("Misc/HostButton")._pressed()
