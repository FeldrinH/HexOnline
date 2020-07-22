extends Button

export(String, MULTILINE) var expression
export(NodePath) var input 

var compiled_expression: Expression = Expression.new()
onready var input_node: Node = get_node(input)
onready var world: Node = get_node("/Root/GameWorld")
onready var network: Node = get_node("/Root/Network")

func _ready():
	compiled_expression.parse(expression, ["input", "world", "network"])
	connect("pressed", self, "__button_pressed")

func __button_pressed():
	compiled_expression.execute([input_node, world, network])
