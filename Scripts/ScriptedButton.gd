extends Button

export(String, MULTILINE) var expression
export(NodePath) var input1
export(NodePath) var input2
export(NodePath) var input3

var world: Node = null
var compiled_expression: Expression = Expression.new()
onready var input1_node: Node = get_node(input1)
onready var input2_node: Node = get_node(input2)
onready var input3_node: Node = get_node(input3)

func init(init_world):
	world = init_world
	var parse_error = compiled_expression.parse(expression, ["input1", "input2", "input3", "world", "network"])
	if parse_error:
		print("PARSE ERROR: " + compiled_expression.get_error_text())

func _pressed():
	compiled_expression.execute([input1_node, input2_node, input3_node, world, world.network])
	if compiled_expression.has_execute_failed():
		print("ERROR: " + compiled_expression.get_error_text())
