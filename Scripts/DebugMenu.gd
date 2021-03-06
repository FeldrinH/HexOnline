extends CanvasLayer

var world: Node

onready var menu_root = $MenuRoot

func _ready():
	menu_root.propagate_call("init", [world])

func _input(event: InputEvent):
	if event.is_action_pressed("ui_toggle_debug_menu"):
		menu_root.visible = !menu_root.visible
		if menu_root.visible:
			refresh_all()

func refresh_all():
	menu_root.propagate_call("refresh")
