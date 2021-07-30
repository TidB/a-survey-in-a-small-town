extends Node

func _ready():
	$bg.play()

func _on_AudioStreamPlayer_finished():
	$bg.play()

func play_sfx():
	$sfx.play()
