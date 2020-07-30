extends Button

onready var console: LineEdit = $"../ConsoleInput"

func _ready():
	connect("pressed", self, "__button_pressed")

func __button_pressed():
	console.execute_line()
