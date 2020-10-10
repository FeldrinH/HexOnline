extends Node2D

onready var wasteland_sprite = preload("res://wasteland_tile_1.tscn")
onready var battle_particles : Particles2D = $BattleParticles
const sounds: Dictionary = {}

func _ready():
	for sound in $Sounds.get_children():
		sounds[sound.name] = sound

func play_sound(sound_name: String):
	sounds[sound_name].play()

func play_battle_effects(target_position):
	battle_particles.position = target_position
	battle_particles.emitting = true
	
	play_sound("battle")

func make_wasteland(position : Vector2):
	var wasteland_instance = wasteland_sprite.instance()
	self.add_child(wasteland_instance)
	wasteland_instance.position = position
	wasteland_instance.rotation = rand_range(0, 360)
