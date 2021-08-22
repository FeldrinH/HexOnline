extends Node

var world: Node

func _ready():
	$MainMenuButtons/VSlider.value = SettingsManager.get_shared("volume")

func set_volume(slider_value):
	SettingsManager.set_shared("volume", slider_value)
	SettingsManager.apply_volume()

func exit_game():
	get_tree().quit()
	
func close_menu():
	world.ui.hide("MainMenu")

func generate_background():
	pass

#func open_settings_menu():
#	$MainMenuButtons.visible = false
#	$SettingsMenu.visible = true
#	$BackButton.visible = true
#
#func close_settings_menu():
#	$MainMenuButtons.visible = true
#	$SettingsMenu.visible = false
#	$BackButton.visible = false
