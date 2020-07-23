extends Button

var compiled_expression: Expression = Expression.new()
onready var console: TextEdit = $"../ConsoleInput"
onready var root: Node = get_node("/root/Root")
onready var world: Node = get_node("/root/Root/World")

func _ready():
	connect("pressed", self, "__button_pressed")

func __button_pressed():
	var parse_error = compiled_expression.parse(console.text, ["world"])
	if parse_error:
		print("> PARSE ERROR: " + compiled_expression.get_error_text())
	else:
		var result = compiled_expression.execute([world], root)
		if compiled_expression.has_execute_failed():
			print("> ERROR: " + compiled_expression.get_error_text())
		else:
			print("> " + str(result))
