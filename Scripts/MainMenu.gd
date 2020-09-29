extends Node

var world
var vol_min = 0.000001

func init(world):
	self.world = world

func set_volume(slider_value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), (log(slider_value)/log(10)) * 20)

func exit_game():
	get_tree().quit()
	
func close_menu():
	world.ui.hide("MainMenu")

func open_settings_menu():
	$MainMenuButtons.visible = false
	$SettingsMenu.visible = true
	$BackButton.visible = true
	
func close_settings_menu():
	$MainMenuButtons.visible = true	
	$SettingsMenu.visible = false
	$BackButton.visible = false
