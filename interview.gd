extends Node2D

class Dialogue:
	pass
	
enum Action {PLAYER, PERSON, FADE}

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
		line = line.strip_edges()
		if line.empty():
			continue
		elif line.begins_with("#"):
			current_time = line.split(" ")[1]
		elif line.begins_with("-"):
			var player_line = line.split(" ", true, 1)[1]
			dialogue[current_time].append([Action.PLAYER, player_line])
		elif line.begins_with("/"):
			var action = line.split(" ")[1]
			if action == "FADE":
				dialogue[current_time].append([Action.FADE])
		elif line.begins_with("|"):
			pass
		else:
			dialogue[current_time].append([Action.PERSON, line])
	
	return dialogue

func play(dialogue):
	var time = Global.TIME_CONFIG[Global.current_time]['offset']
	for line in dialogue[str(time)]:
		if line[0] in [Action.PLAYER, Action.PERSON]:
			var box
			var tween
			if line[0] == Action.PLAYER:
				box = $PlayerSpeech
				tween = $TweenPlayer
			elif line[0] == Action.PERSON:
				box = $PersonSpeech
				tween = $TweenPerson
				
			tween.interpolate_method(box, "set_percent_visible", 0.0, 1.0, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			tween.start()

			box.bbcode_text = line[1]
			
			var word_count = len(line[1].split(" "))
			var reading_time = max(1.5, word_count / 225.0 * 60)
			print(word_count, " words, equals ", reading_time, " seconds")
			timer.start(reading_time)
			yield(timer, "timeout")
			
			tween.interpolate_method(box, "set_percent_visible", 1.0, 0.0, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			tween.start()
		elif line[0] == Action.FADE:
			$TweenFade.interpolate_property($Fade, "color", Color(0, 0, 0, 0), Color(0, 0, 0, 1), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$TweenFade.start()
			
			yield($TweenFade, "tween_completed")
			
			$TweenFade.interpolate_property($Fade, "color", Color(0, 0, 0, 1), Color(0, 0, 0, 0), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$TweenFade.start()
			
			timer.start(1)
			yield(timer, "timeout")
