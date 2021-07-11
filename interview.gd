extends Node2D

class Dialogue:
	pass
	
enum Subject {PLAYER, PERSON}

var timer

func _ready():
	$person.person = Global.interview_person
	$Background.color = Global.get_bg_color()
	timer = Timer.new()
	add_child(timer)
	var dialogue = parse_dialogue(Global.name(Global.interview_person))
	play(dialogue)
	
func parse_dialogue(name):
	var file = File.new()
	file.open("res://dialogue/" + name + ".txt", File.READ)
	var content = file.get_as_text()
	file.close()
	
	var dialogue = {}
	for t in Global.TIME_CONFIG:
		dialogue[str(t['offset'])] = []
	
	var current_time = null
	for line in content.strip_edges().split("\n"):
		if line.strip_edges().empty():
			continue
		elif line.begins_with("#"):
			current_time = line.split(" ")[1]
		elif line.begins_with("-"):
			var player_line = line.split(" ", true, 1)[1].strip_edges()
			dialogue[current_time].append([Subject.PLAYER, player_line])
		else:
			dialogue[current_time].append([Subject.PERSON, line.strip_edges()])
	
	return dialogue

func play(dialogue):
	var time = Global.TIME_CONFIG[Global.current_time]['offset']
	for line in dialogue[str(time)]:
		var box
		if line[0] == Subject.PLAYER:
			box = $PlayerSpeech
		elif line[0] == Subject.PERSON:
			box = $PersonSpeech
			
		$Tween.interpolate_method(box, "set_percent_visible", 0.0, 1.0, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()

		box.text = line[1]
			
		var word_count = len(line[1].split(" "))
		var reading_time = max(1.5, word_count / 225.0 * 60)
		print(word_count, " words, equals ", reading_time, " seconds")
		timer.start(reading_time)
		yield(timer, "timeout")
		
		$Tween.interpolate_method(box, "set_percent_visible", 1.0, 0.0, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
