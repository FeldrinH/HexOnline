extends Node2D

onready var wasteland_sprite = preload("res://wasteland_tile_1.tscn")
onready var battle_particles : Particles2D = $BattleParticles
onready var sounds_timer : Timer = $SoundsTimer

const sounds: Dictionary = {}
var last_sound

func _ready():
	for sound in $Sounds.get_children():
		sounds[sound.name] = sound
	sounds_timer.connect("timeout", self, "reset_sounds")
	sounds_timer.one_shot = true

func play_sound(sound_name: String):
	if last_sound:
		if last_sound != sound_name:
			play_sound_clip(sound_name)
	else:
		play_sound_clip(sound_name)

func play_sound_clip(sound_name):
	sounds[sound_name].play()
	last_sound = sound_name
	sounds_timer.start(get_sound_delay(sound_name))

func get_sound_delay(sound_name):
	if sound_name == "ship_movement":
		return 1.2
	else:
		return 0.4
		
func reset_sounds():
	last_sound = null

func play_battle_effects(target_position):
	battle_particles.position = target_position
	battle_particles.emitting = true
	
	play_sound("battle")

func make_wasteland(position : Vector2):
	var wasteland_instance = wasteland_sprite.instance()
	self.add_child(wasteland_instance)
	wasteland_instance.position = position
	wasteland_instance.rotation = rand_range(0, 360)
