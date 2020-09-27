extends Node2D

const marching_clip = preload("res://Sounds/march.ogg")
const battle_clip = preload("res://Sounds/battle_sound.ogg")
const ship_clip = preload("res://Sounds/ship_horn_1.ogg")
const announcement_clip = preload("res://Sounds/announcement.ogg")

onready var wasteland_sprite = preload("res://wasteland_tile_1.tscn")
onready var battle_sound_player : AudioStreamPlayer = $BattleSoundPlayer
onready var movement_sound_player : AudioStreamPlayer = $MovementSoundPlayer
onready var ship_sound_player : AudioStreamPlayer = $ShipSoundPlayer
onready var announcement_sound_player : AudioStreamPlayer = $AnnouncementSoundPlayer
onready var battle_particles : Particles2D = $BattleParticles

func _ready():
	movement_sound_player.stream = marching_clip
	battle_sound_player.stream = battle_clip
	ship_sound_player.stream = ship_clip
	announcement_sound_player.stream = announcement_clip

#func play_audio(play_stream : AudioStream):
#	if audio_player.stream != play_stream:
#		audio_player.stream = play_stream
#
#	audio_player.play()

func play_movement_effects():
	movement_sound_player.play()

func play_ship_sound():
	ship_sound_player.play()

func play_battle_effects(target_position):
	battle_particles.position = target_position
	battle_particles.emitting = true
	
	battle_sound_player.play()
	
func play_announcement():
	announcement_sound_player.play()
	
func make_wasteland(position : Vector2):
	var wasteland_instance = wasteland_sprite.instance()
	self.add_child(wasteland_instance)
	wasteland_instance.position = position
	wasteland_instance.rotation = rand_range(0, 360)
