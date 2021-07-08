extends Node2D

func _ready():
	$person.person = Global.interview_person
	$Background.color = Global.get_bg_color()
