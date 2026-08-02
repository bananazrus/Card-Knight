extends Node

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer2D

@onready var boss_audio_player: AudioStreamPlayer = $AudioStreamPlayer2D2

func play_music(stream: AudioStream):
	if audio_player.stream == stream and audio_player.playing:
		return
	audio_player.stream = stream
	audio_player.play()
func play_boss_music(stream: AudioStream):
	if boss_audio_player.stream == stream and boss_audio_player.playing:
		return
	boss_audio_player.stream = stream
	boss_audio_player.play()
func stop_music():
	audio_player.stop()
func stop_boss_music():
	boss_audio_player.stop()
