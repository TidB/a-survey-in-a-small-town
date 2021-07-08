extends Area2D

export (Global.Person) var person setget set_person
export (bool) var active setget set_active 

signal entered(name)
signal exited(name)
signal clicked(name)

func _ready():
	$CollisionPolygon2D.polygon = $Polygon2D.polygon
	set_person(person)

func set_person(value):
	person = value
	
	for face in $Faces.get_children():
		face.visible = face.name == person_str()

func set_active(value):
	active = value
	$Faces.get_node(person_str()).visible = active
	$Faces/Unavailable.visible = not active
	$Polygon2D.color = Color.white if active else Color.darkgray

func _on_person_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton && event.pressed && active):
		emit_signal("clicked", self)

func person_str():
	return Global.Person.keys()[person]

func _on_person_mouse_entered():
	emit_signal("entered", self)

func _on_person_mouse_exited():
	emit_signal("exited", self)
