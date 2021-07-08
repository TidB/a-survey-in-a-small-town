extends Node2D

export(int) var start_time = 3

const TIME_CONFIG = [
	{
		'offset': -40,
		'name': '40 years ago',
		'avail': [Global.Person.Ralf, Global.Person.Mary, Global.Person.Alison, Global.Person.Emily, Global.Person.Alex, Global.Person.Nelly],
		'rift': []
	},
	{
		'offset': -25,
		'name': '25 years ago',
		'avail': [Global.Person.Ralf, Global.Person.Mary, Global.Person.Alex, Global.Person.Emily, Global.Person.Nelly],
		'rift': []
	},
	{
		'offset': -2,
		'name': '2 years ago',
		'avail': [Global.Person.Mary, Global.Person.Alex, Global.Person.Emily,  Global.Person.Nelly],
		'rift': []
	},
	{
		'offset': 0,
		'name': 'Today',
		'avail': [Global.Person.Alex, Global.Person.Emily, Global.Person.Nelly],
		'rift': ['Small']
	},
	{
		'offset': 5,
		'name': '5 years in the future',
		'avail': [Global.Person.Emily, Global.Person.Nelly],
		'rift': ['Medium']
	},
	{
		'offset': 20,
		'name': '20 years in the future',
		'avail': [Global.Person.Emily, Global.Person.Nelly],
		'rift': ['Large']
	},
	{
		'offset': 60,
		'name': '60 years in the future',
		'avail': [Global.Person.Nelly],
		'rift': ['Final', 'FinalBase']
	},
]

func _ready():
	Global.current_time = start_time
	update_time(Global.current_time)
	
	for person in $People.get_children():
		person.connect("entered", self, "_on_person_mouse_entered")
		person.connect("exited", self, "_on_person_mouse_exited")
		person.connect("clicked", self, "_on_person_mouse_clicked")

func update_time(value):
	update_label(value)
	update_bg(value)
	update_indicator(value)
	update_avail(value)
	update_rift(value)
	
func update_label(value):
	$Timeline/Label.text = TIME_CONFIG[value]['name']
		
func update_bg(value):
	$TownCutout.color = Global.get_bg_color()
	
func update_indicator(value):
	var min_pos = 0
	var max_pos = ProjectSettings.get_setting("display/window/size/width")
	var ratio = value / float(Global.timelines - 1)
	var pos = lerp(min_pos, max_pos, ratio)
	$Timeline/Indicator.position.x = pos
	
func update_avail(value):
	for person in $People.get_children():
		person.active = person.person in TIME_CONFIG[value]['avail']
	
func update_rift(value):
	for rift in $Rift.get_children():
		rift.visible = rift.name in TIME_CONFIG[value]['rift']
	
func _on_person_mouse_entered(person):
	if person.active:
		$Selection.text = "Interview " + person.person_str()
	else:
		$Selection.text = "Interviewee unavailable"

func _on_person_mouse_exited(person):
	$Selection.text = ""
	
func _on_person_mouse_clicked(person):
	Global.switch_to_interview(person.person)

