extends Node2D

onready var audio_player : AudioStreamPlayer = $AudioStreamPlayer
onready var battle_particles : Particles2D = $BattleParticles

func play_audio(play_stream : AudioStream):
	if audio_player.stream != play_stream:
		audio_player.stream = play_stream
	
	audio_player.play()

func play_battle_effects(target_position):
	battle_particles.position = target_position
	battle_particles.emitting = true
