extends Node

enum Person {Mary, Alison, Emily, Alex, Nelly}
var AUTO_ADVANCE = false
var TEXT_SPEED = 1.0
enum ReportState {Survey, Assignment, Evaluation}

const ORDER = [2, 1, 3, 4, 0, 5]
const TIME_CONFIG = [
	{
		'offset': -40,
		'name': '40 years ago',
		'avail': [Person.Mary, Person.Alison, Person.Emily, Person.Alex, Person.Nelly],
		'rift': [],
		'wind': [0, 0, 0],
		'asgmt': '\nRound 5: Timeline -40\n\nThis is technically the first interview, so no choices yet :)\n\nThe survey\'s taking a bit long, it would be AWESOME if you could hurry up a bit!! <3\n\nFind the questions in attachment 5-1.',
		'eval': 'Good job!\nThe interviewees think it is just another survey!',
		'happy': {
			Person.Mary: 100,
			Person.Alison: 80,
			Person.Alex: 90,
			Person.Emily: 90,
			Person.Nelly: 100,
		},
	},
	{
		'offset': -25,
		'name': '25 years ago',
		'avail': [Person.Mary, Person.Alex, Person.Emily, Person.Nelly],
		'rift': [],
		'wind': [0, 0, 0],
		'asgmt': '\nRound 2: Timeline -25\n\nThis is technically only their second interview, so no choices yet :)\n\nFind the questions in attachment 2-1.',
		'eval': 'One down, only four more to go ;)\n\nSeems like it won\'t take much longer!!',
		'happy': {
			Person.Mary: 100,
			Person.Alex: 90,
			Person.Emily: 80,
			Person.Nelly: 100,
		},
	},
	{
		'offset': 0,
		'name': 'Today',
		'avail': [Person.Alex, Person.Emily, Person.Nelly],
		'rift': ['Small'],
		'wind': [1000, -5, 3],
		'asgmt': '\nRound 1: Timeline ±0\n\nYou have a couple choices, use them wisely :)\n\nFind the questions in attachment 1-1.',
		'eval': 'Not bad for your first temporal interview, you\'re making great progress! :D',
		'happy': {},
	},
	{
		'offset': 5,
		'name': '5 years in the future',
		'avail': [Person.Alex, Person.Emily, Person.Nelly],
		'rift': ['Medium'],
		'wind': [2500, -10, 3],
		'asgmt': '\nRound 3: Timeline +5\n\nYou have a couple choices, use them wisely :)\n\nFind the questions in attachment 3-1.',
		'eval': 'Looking good!!',
		'happy': {},
	},
	{
		'offset': 20,
		'name': '20 years in the future',
		'avail': [Person.Emily, Person.Nelly],
		'rift': ['Large'],
		'wind': [7500, -20, 3.1],
		'asgmt': '\nRound 4: Timeline +20\n\nYou have a couple more choices, use them wisely :)\n\nFind the questions in attachment 4-1.',
		'eval': 'We\'re almost done!! Now a small detour to plant the seeds of doubt ;)',
		'happy': {},
	},
	{
		'offset': 60,
		'name': '60 years in the future',
		'avail': [Person.Nelly],
		'rift': ['Final', 'FinalBase'],
		'wind': [20000, -20, 3.2],
		'asgmt': '\nRound 6: Timeline +60\n\nWe almost did it!!\n\nGET.\nTHIS.\nDONE.\n;)\n\nFind the questions in attachment 6-1.',
		'eval': 'We did it!!!!!\n\nOne down, only fifteen more to go ;)\n\nPlease visit the recreational facilities to fully restore your mental state before starting the next survey!',
		'happy': {},
	}
]

var choices = {}
var picked = []

var happiness = {
	Person.Alex: 90,
	Person.Emily: 80,
	Person.Nelly: 100,
}

var timelines = 6
var current_step = 0
var current_time setget ,get_current_time
var current_config setget ,get_current_config
var report_state = ReportState.Survey
var productivity = 50
var current_cooldown = 0
var interview_person

func _ready():
	self.set_pause_mode(2)

func _input(event):
	if event.is_action_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen

func get_current_config():
	return TIME_CONFIG[self.current_time]

func get_current_time():
	return ORDER[current_step]
	
func decrease_cooldown():
	current_cooldown = clamp(current_cooldown - 1, 0, 3)

func reset_cooldown():
	current_cooldown = 3
	
func average_happiness():
	var sum = 0
	for person in self.current_config["avail"]:
		if person in happiness:
			sum += happiness[person]
		else:
			sum += self.current_config["happy"][person]
	return sum / len(self.current_config["avail"])

func switch_to_interview(person):
	interview_person = person
	get_tree().change_scene("res://interview.tscn")
	
func interview_finished():
	if len(picked) >= len(self.current_config["avail"]):
		report_state = ReportState.Evaluation
		picked = []
		get_tree().change_scene("res://assignment.tscn")
	else:
		get_tree().change_scene("res://start.tscn")

func evaluation_finished():
	if report_state == ReportState.Evaluation or report_state == ReportState.Survey:
		if report_state == ReportState.Evaluation:
			current_step += 1
			if current_step >= timelines:
				get_tree().change_scene("res://end.tscn")
				return
		report_state = ReportState.Assignment
		get_tree().change_scene("res://assignment.tscn")
	else:
		Audio.play_sfx()
		get_tree().change_scene("res://start.tscn")

func get_bg_color():
	var gradient = load("res://bg_gradient.tres").gradient
	return gradient.interpolate(self.current_time / float(timelines - 1))

func name(person):
	return Global.Person.keys()[person]
