extends LineEdit

var world: Node = null
var compiled_expression: Expression = Expression.new()

func init(init_world):
	world = init_world

func _gui_input(event):
	if event.is_action_pressed("ui_accept"):
		execute_line()

func execute_line():
	var parse_error = compiled_expression.parse(text, ["world", "OS"])
	if parse_error:
		print("> PARSE ERROR: " + compiled_expression.get_error_text())
	else:
		var result = compiled_expression.execute([world, OS], null)
		if compiled_expression.has_execute_failed():
			print("> ERROR: " + compiled_expression.get_error_text())
		else:
			print("> " + str(result))
