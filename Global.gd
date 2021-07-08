extends Node

enum Person {Ralf, Mary, Alison, Emily, Alex, Nelly}

var timelines = 7
var current_time
var interview_person

func _ready():
	self.set_pause_mode(2)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().paused = !get_tree().paused
	elif event.is_action_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen

func switch_to_interview(person_str):
	interview_person = person_str
	get_tree().change_scene("res://interview.tscn")

func get_bg_color():
	var gradient = load("res://bg_gradient.tres").gradient
	return gradient.interpolate(current_time / float(timelines - 1))
