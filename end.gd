extends Node2D

var start 
func _ready():
	start = OS.get_ticks_msec()

func _input(event):
	if event.is_action_pressed("advance") and (OS.get_ticks_msec() - start) > 1000:
		get_tree().quit()
