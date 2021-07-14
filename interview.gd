extends Node2D

class Dialogue:
	pass
	
enum Action {PLAYER, PERSON, FADE, CHOICE}
signal choice_picked

var timer
var choices = []
var happiness = 100
var productivity = 50

func _ready():
	$person.person = Global.interview_person
	$Background.color = Global.get_bg_color()
	$Choice/Choice1Bg/CollisionPolygon2D.polygon = $Choice/Choice1Bg/Polygon2D.polygon
	$Choice/Choice2Bg/CollisionPolygon2D.polygon = $Choice/Choice2Bg/Polygon2D.polygon
	update_values()
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
	var skip = false
	var condition = []
	for line in content.strip_edges().split("\n"):
		line = line.strip_edges()
		if line.empty():
			condition = []
			skip = false
		elif line.begins_with("#"):
			current_time = line.split(" ")[1]
		elif line.begins_with("/"):
			var action = line.split(" ")[1]
			if action == "FADE":
				dialogue[current_time].append([Action.FADE])
			elif action == "SKIP":
				skip = true
		elif line.begins_with("|"):
			var args = line.split(",")
			dialogue[current_time].append([Action.CHOICE, int(args[1]), args[2], args[3]])
		elif line.begins_with("="):
			var args = line.split(" ")
			condition = [int(args[1]), int(args[2])]
		elif line.begins_with("-"):
			var player_line = line.split(" ", true, 1)[1]
			dialogue[current_time].append([Action.PLAYER, player_line, condition, skip])
		else:
			dialogue[current_time].append([Action.PERSON, line, condition, skip])
	
	return dialogue

func play(dialogue):
	var time = Global.TIME_CONFIG[Global.current_time]['offset']
	for line in dialogue[str(time)]:
		if line[0] in [Action.PLAYER, Action.PERSON]:
			if line[2]:
				if choices[line[2][0]] != line[2][1]:
					continue
			
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
			var reading_time = max(1.5, word_count / 225.0 * 60) / Global.TEXT_SPEED
			if line[3]:
				reading_time = 3
			print(word_count, " words, equals ", reading_time, " seconds")
			timer.start(reading_time)
			yield(timer, "timeout")
			
			tween.interpolate_method(box, "set_percent_visible", 1.0, 0.0, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			tween.start()
		elif line[0] == Action.CHOICE:
			$PlayerSpeech.visible = false
			$PlayerSpeechBg.visible = false
			$Choice.visible = true
			
			$Choice/Choice1.bbcode_text = "[center]%s[/center]" % line[2]
			$Choice/Choice2.bbcode_text = "[center]%s[/center]" % line[3]
			
			yield(self, "choice_picked")
			
			$PlayerSpeech.visible = true
			$PlayerSpeechBg.visible = true
			$Choice.visible = false
		elif line[0] == Action.FADE:
			$TweenFade.interpolate_property($Fade, "color", Color(0, 0, 0, 0), Color(0, 0, 0, 1), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$TweenFade.start()
			
			yield($TweenFade, "tween_completed")
			
			$TweenFade.interpolate_property($Fade, "color", Color(0, 0, 0, 1), Color(0, 0, 0, 0), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$TweenFade.start()
			
			timer.start(1)
			yield(timer, "timeout")
	
	$TweenFade.interpolate_property($Fade, "color", Color(0, 0, 0, 0), Color(0, 0, 0, 1), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$TweenFade.start()
	
	yield($TweenFade, "tween_completed")
	
	timer.start(1)
	yield(timer, "timeout")
	Global.switch_to_town()

func _on_Choice1Bg_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton && event.pressed):
		choice(0)

func _on_Choice2Bg_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton && event.pressed):
		choice(1)
		
func choice(num):
	if num and productivity <= 10:
		$Choice/Choice2.bbcode_text = "Your productivity is too low to choose this option"
		return
	
	# 0 = bad, 1 = good. innovative & nuanced
	if not num: 
		happiness = clamp(happiness - 30, 0, 100)
		productivity = clamp(productivity + 30, 0, 100)
	else:
		happiness = clamp(happiness + 30, 0, 100)
		productivity = clamp(productivity - 30, 0, 100)
	update_values()
	choices.append(num)
	emit_signal("choice_picked")

func update_values():
	$Values/HappyLabel.text = "%s's Happiness: %d%%" % [Global.name(Global.interview_person), happiness]
	$Values/ProdLabel.text = "Your Productivity: %d%%" % productivity
