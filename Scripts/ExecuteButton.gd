extends Button

onready var console: LineEdit = $"../ConsoleInput"

func init(init_world):
	connect("pressed", self, "__button_pressed")

func __button_pressed():
	console.execute_line()
