extends Node2D

export(int) var start_time = 2

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
	update_wind(value)
	
func update_label(value):
	$Timeline/Label.text = Global.TIME_CONFIG[value]['name']
		
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
		if person.name() in Global.picked:
			person.done = true
		else:
			person.active = person.person in Global.TIME_CONFIG[value]['avail']
	
func update_rift(value):
	for rift in $Rift.get_children():
		rift.visible = rift.name in Global.TIME_CONFIG[value]['rift']
		
func update_wind(value):
	var amount = Global.TIME_CONFIG[value]['wind'][0]
	if amount:
		$Particles2D.emitting = true
		$Particles2D.amount = amount
	else:
		$Particles2D.emitting = false
	$Particles2D.process_material.radial_accel = Global.TIME_CONFIG[value]['wind'][1]
	$Particles2D.process_material.scale = Global.TIME_CONFIG[value]['wind'][2]
	
func _on_person_mouse_entered(person):
	if person.active:
		$Helper/Selection.text = "Interview " + person.name()
	elif person.done:
		$Helper/Selection.text = "Interview done"
	else:
		$Helper/Selection.text = "Interviewee unavailable"

func _on_person_mouse_exited(person):
	$Helper/Selection.text = ""
	
func _on_person_mouse_clicked(person):
	if person.name() == "Alex" and Global.picked[-1] == "Nelly":
		Global.choices["-25nellyVisitedBeforeAlex"] = 1
	Global.picked.append(person.name())
	
	Global.switch_to_interview(person.person)

