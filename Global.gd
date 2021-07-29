extends Node

enum Person {Mary, Alison, Emily, Alex, Nelly}
const TEXT_SPEED = 1.0
enum ReportState {Survey, Assignment, Evaluation}

const ORDER = [2, 1, 3, 4, 0, 5]
const TIME_CONFIG = [
	{
		'offset': -40,
		'name': '40 years ago',
		'avail': [Person.Mary, Person.Alison, Person.Emily, Person.Alex, Person.Nelly],
		'rift': [],
		'wind': [0, 0, 0],
		'asgmt': '\nRound 5: Timeline -40\n\nThis is technically the first interview, so no choices yet :)\n\nFind the questions in attachment 5-1.',
	},
	{
		'offset': -25,
		'name': '25 years ago',
		'avail': [Person.Mary, Person.Alex, Person.Emily, Person.Nelly],
		'rift': [],
		'wind': [0, 0, 0],
		'asgmt': '\nRound 2: Timeline -25\n\nThis is technically only their second interview, so no choices yet :)\n\nFind the questions in attachment 2-1.',
	},
	{
		'offset': 0,
		'name': 'Today',
		'avail': [Person.Alex, Person.Emily, Person.Nelly],
		'rift': ['Small'],
		'wind': [1000, -5, 3],
		'asgmt': '\nRound 1: Timeline ±0\n\nYou have a couple choices, use them wisely :)\n\nFind the questions in attachment 1-1.',
	},
	{
		'offset': 5,
		'name': '5 years in the future',
		'avail': [Person.Alex, Person.Emily, Person.Nelly],
		'rift': ['Medium'],
		'wind': [2500, -10, 3],
		'asgmt': '\nRound 3: Timeline +5\n\nYou have a couple choices, use them wisely :)\n\nFind the questions in attachment 3-1.',
	},
	{
		'offset': 20,
		'name': '20 years in the future',
		'avail': [Person.Emily, Person.Nelly],
		'rift': ['Large'],
		'wind': [7500, -20, 3.1],
		'asgmt': '\nRound 4: Timeline +20\n\nYou have a couple choices, use them wisely :)\n\nFind the questions in attachment 4-1.',
	},
	{
		'offset': 60,
		'name': '60 years in the future',
		'avail': [Person.Nelly],
		'rift': ['Final', 'FinalBase'],
		'wind': [20000, -20, 3.2],
		'asgmt': '\nRound 6: Timeline +60\n\nWe almost did it!! You have a couple choices, use them wisely :)\n\nFind the questions in attachment 6-1.',
	},
]

var choices = {}
var picked = []

var timelines = 6
var current_step = 5
var current_time setget ,get_current_time
var current_config setget ,get_current_config
var report_state = ReportState.Survey
var productivity = 50
var interview_person

func _ready():
	self.set_pause_mode(2)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().paused = !get_tree().paused
	elif event.is_action_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen

func get_current_config():
	return TIME_CONFIG[self.current_time]

func get_current_time():
	return ORDER[current_step]

func switch_to_interview(person):
	interview_person = person
	get_tree().change_scene("res://interview.tscn")
	
func interview_finished():
	if len(picked) >= len(self.current_config["avail"]):
		current_step += 1
		report_state = ReportState.Evaluation
		picked = []
		get_tree().change_scene("res://assignment.tscn")
	else:
		get_tree().change_scene("res://start.tscn")

func evaluation_finished():
	if report_state == ReportState.Evaluation or report_state == ReportState.Survey:
		report_state = ReportState.Assignment
		get_tree().change_scene("res://assignment.tscn")
	else: 
		get_tree().change_scene("res://start.tscn")

func get_bg_color():
	var gradient = load("res://bg_gradient.tres").gradient
	return gradient.interpolate(self.current_time / float(timelines - 1))

func name(person):
	return Global.Person.keys()[person]
