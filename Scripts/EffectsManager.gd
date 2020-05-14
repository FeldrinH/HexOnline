extends Node2D

const marching_clip = preload("res://Sounds/march.ogg")
const battle_clip = preload("res://Sounds/battle_sound.ogg")

onready var battle_sound_player : AudioStreamPlayer = $BattleSoundPlayer
onready var movement_sound_player : AudioStreamPlayer = $MovementSoundPlayer
onready var battle_particles : Particles2D = $BattleParticles

func _ready():
	movement_sound_player.stream = marching_clip
	battle_sound_player.stream = battle_clip

#func play_audio(play_stream : AudioStream):
#	if audio_player.stream != play_stream:
#		audio_player.stream = play_stream
#
#	audio_player.play()

func play_movement_effects():
	movement_sound_player.play()

func play_battle_effects(target_position):
	battle_particles.position = target_position
	battle_particles.emitting = true
	
	battle_sound_player.play()
