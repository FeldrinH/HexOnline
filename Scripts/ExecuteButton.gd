extends Button

var compiled_expression: Expression = Expression.new()
onready var console: TextEdit = $"../ConsoleInput"
onready var world: Node = get_node("/Root/GameWorld")
onready var network: Node = get_node("/Root/Network")

func _ready():
	connect("pressed", self, "__button_pressed")

func __button_pressed():
	compiled_expression.parse(console.text, ["world", "network"])
	compiled_expression.execute([world, network])
