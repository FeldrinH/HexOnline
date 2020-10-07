extends LineEdit

export var variable_name: String = ""
var variable_nav: Array = []

func _ready():
	variable_nav = variable_name.split(".")
	text = get_var()
	connect("text_changed", self, "set_var")

func get_var():
	if len(variable_nav) == 2:
		var dict = SettingsManager.get_shared(variable_nav[0])
		return dict[variable_nav[1]]
	else:
		return SettingsManager.get_shared(variable_name)

func set_var(new_val):
	if len(variable_nav) == 2:
		var dict = SettingsManager.get_shared(variable_nav[0])
		dict[variable_nav[1]] = new_val
	else:
		SettingsManager.set_shared(variable_name, new_val)
