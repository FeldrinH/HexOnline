extends "CityBase.gd"

onready var port_icon = $PortIcon
onready var city_icon = $CityIcon

puppet func make_port():
	is_port = true
	port_icon.visible = true
	city_icon.visible = false
