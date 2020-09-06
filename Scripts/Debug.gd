extends CanvasLayer

var initialized = false
onready var menu_root = $MenuRoot
onready var world = $".."

func _ready():
	world.connect("ready", self, "initialize")
	world.connect("ready", self, "autosetup")

func initialize():
	menu_root.propagate_call("init", [world])
	initialized = true

func _input(event: InputEvent):
	if event.is_action_pressed("ui_toggle_debug_menu") and initialized:
		menu_root.visible = !menu_root.visible
		if menu_root.visible:
			refresh_all()

func refresh_all():
	assert(initialized)
	menu_root.propagate_call("refresh")


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
	refresh_all()
