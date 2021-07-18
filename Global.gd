extends Node

enum Person {Ralf, Mary, Alison, Emily, Alex, Nelly}
const TEXT_SPEED = 2.0

const TIME_CONFIG = [
	{
		'offset': -40,
		'name': '40 years ago',
		'avail': [Person.Ralf, Person.Mary, Person.Alison, Person.Emily, Person.Alex, Person.Nelly],
		'rift': []
	},
	{
		'offset': -25,
		'name': '25 years ago',
		'avail': [Person.Ralf, Person.Mary, Person.Alex, Person.Emily, Person.Nelly],
		'rift': []
	},
	{
		'offset': -2,
		'name': '2 years ago',
		'avail': [Person.Mary, Person.Alex, Person.Emily,  Person.Nelly],
		'rift': []
	},
	{
		'offset': 0,
		'name': 'Today',
		'avail': [Person.Alex, Person.Emily, Person.Nelly],
		'rift': ['Small']
	},
	{
		'offset': 5,
		'name': '5 years in the future',
		'avail': [Person.Emily, Person.Nelly],
		'rift': ['Medium']
	},
	{
		'offset': 20,
		'name': '20 years in the future',
		'avail': [Person.Emily, Person.Nelly],
		'rift': ['Large']
	},
	{
		'offset': 60,
		'name': '60 years in the future',
		'avail': [Person.Nelly],
		'rift': ['Final', 'FinalBase']
	},
]

var timelines = 7
var current_time
var productivity = 50
var interview_person

func _ready():
	self.set_pause_mode(2)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().paused = !get_tree().paused
	elif event.is_action_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen

func switch_to_interview(person):
	interview_person = person
	get_tree().change_scene("res://interview.tscn")
	
func switch_to_town():
	get_tree().change_scene("res://start.tscn")

func get_bg_color():
	var gradient = load("res://bg_gradient.tres").gradient
	return gradient.interpolate(current_time / float(timelines - 1))

func name(person):
	return Global.Person.keys()[person]
