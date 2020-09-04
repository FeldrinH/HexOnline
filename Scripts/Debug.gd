extends Node

# Debug helper

onready var debug_menu = $"/root/Root/DebugMenu"
onready var world = $".."

func _ready():
	$"/root".connect("ready", self, "autosetup")

# Run after scene tree has initialized
func autosetup():
	if OS.has_feature("editor"):
		autosetup_debug()
		if len(OS.get_cmdline_args()) >= 1 and OS.get_cmdline_args()[0] == "--autosetup_editor":
			autosetup_editor()

# Run on autosetup when started from editor or project manager
func autosetup_debug():
	#print("Running debug autosetup...")
	pass

# Run on autosetup when started from editor
func autosetup_editor():
	print("Running editor autosetup...")
	world.network.create_server("Server Host Man")
	world.network.our_client.rpc("set_player_id", 0)
	debug_menu.refresh_all()
