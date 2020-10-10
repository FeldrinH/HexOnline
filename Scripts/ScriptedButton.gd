extends TextureButton

export(String, MULTILINE) var expression
export(NodePath) var input1
export(NodePath) var input2
export(NodePath) var input3

var compiled_expression: Expression = Expression.new()
onready var input1_node: Node = get_node(input1)
onready var input2_node: Node = get_node(input2)
onready var input3_node: Node = get_node(input3)
onready var tree_node: SceneTree = get_tree()

func _ready():
	var parse_error = compiled_expression.parse(expression, ["input1", "input2", "input3"])
	if parse_error:
		print("PARSE ERROR: " + compiled_expression.get_error_text())
	else:
		print("PARSE OK")

func _pressed():
	compiled_expression.execute([input1_node, input2_node, input3_node], self)
	if compiled_expression.has_execute_failed():
		print("ERROR: " + compiled_expression.get_error_text())
