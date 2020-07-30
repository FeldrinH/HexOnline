extends LineEdit

var compiled_expression: Expression = Expression.new()
onready var root: Node = get_node("/root/Root")
onready var world: Node = get_node("/root/Root/World")

func _gui_input(event):
	if event.is_action_pressed("ui_accept"):
		execute_line()

func execute_line():
	var parse_error = compiled_expression.parse(text, ["world", "OS"])
	if parse_error:
		print("> PARSE ERROR: " + compiled_expression.get_error_text())
	else:
		var result = compiled_expression.execute([world, OS], root)
		if compiled_expression.has_execute_failed():
			print("> ERROR: " + compiled_expression.get_error_text())
		else:
			print("> " + str(result))
