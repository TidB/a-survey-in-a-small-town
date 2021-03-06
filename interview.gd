extends Node2D

const MINIMUM_WAIT = 700
	
enum Action {PLAYER, PERSON, FADE, FADEPARTIAL, CHOICE}
signal choice_picked
signal advance

var last_line = OS.get_ticks_msec()
var current_choice
var timer
var happiness
var loop = 0
var gradient = load("res://bg_gradient.tres").gradient
var blink_timer
var bright = true

func _ready():
	if Global.current_config["happy"]:
		happiness = Global.current_config["happy"][Global.interview_person]
	else:
		happiness = Global.happiness[Global.interview_person]
	$person.person = Global.interview_person
	$Background.color = Global.get_bg_color()
	$Choice/Choice1Bg/CollisionPolygon2D.polygon = $Choice/Choice1Bg/Polygon2D.polygon
	$Choice/Choice2Bg/CollisionPolygon2D.polygon = $Choice/Choice2Bg/Polygon2D.polygon
	$PlayerSpeech.set_percent_visible(0)
	$PersonSpeech.set_percent_visible(0)
	timer = Timer.new()
	add_child(timer)
	blink_timer = Timer.new()
	blink_timer.connect("timeout", self, "_on_blink_timer_timeout")
	add_child(blink_timer)
	update_values()
	var dialogue = parse_dialogue(Global.name(Global.interview_person))
	play(dialogue)
	
func parse_dialogue(name):
	var file = File.new()
	file.open("res://dialogue/" + name.to_lower() + ".txt", File.READ)
	var content = file.get_as_text()
	file.close()
	
	var dialogue = {}
	for t in Global.TIME_CONFIG:
		dialogue[str(t['offset'])] = []
	
	var current_time = null
	var skip = false
	var rate = []
	var last_cond = null
	var condition = []
	for line in content.strip_edges().split("\n"):
		line = line.strip_edges()
		if line.empty():
			condition = []
			skip = false
			rate = []
			last_cond = null
		elif line.begins_with("#"):
			current_time = line.split(" ")[1]
		elif line.begins_with("/"):
			var action = line.split(" ")[1]
			if action == "FADE":
				dialogue[current_time].append([Action.FADE])
			elif action == "FADEPARTIAL":
				dialogue[current_time].append([Action.FADEPARTIAL])
			elif action == "SKIP":
				skip = true
			elif action == "RATE":
				var args = line.split(" ")
				rate = [int(args[2]), int(args[3])]
		elif line.begins_with("|"):
			var args = line.split(",")
			dialogue[current_time].append([Action.CHOICE, args[1], args[2], args[3]])
		elif line.begins_with("="):
			if not last_cond == null:
				condition = [last_cond, 1]
			else:
				var args = line.split(" ")
				condition = [args[1], 0]
				last_cond = args[1]
		elif line.begins_with("-"):
			var player_line = line.split(" ", true, 1)[1]
			dialogue[current_time].append([Action.PLAYER, player_line, condition, skip, rate])
			skip = false
			rate = []
		else:
			dialogue[current_time].append([Action.PERSON, line, condition, skip, rate])
			skip = false
			rate = []
	
	return dialogue

func play(dialogue):
	var time = Global.TIME_CONFIG[Global.current_time]['offset']
	for line in dialogue[str(time)]:
		if line[0] in [Action.PLAYER, Action.PERSON]:
			var condition = line[2]
			if condition:
				if condition[0] in Global.choices:
					if Global.choices[condition[0]] != condition[1]:
						continue
				else:
					print("Choice '", condition[0], "' not defined!")
					continue
				
			var rate = line[4]	
			if rate:
				happiness = clamp(happiness + rate[0], 0, 100)
				Global.productivity = clamp(Global.productivity + rate[1], 0, 100)
				update_values()
			
			var box
			var tween
			if line[0] == Action.PLAYER:
				box = $PlayerSpeech
				tween = $TweenPlayer
			elif line[0] == Action.PERSON:
				box = $PersonSpeech
				tween = $TweenPerson
			
			last_line = OS.get_ticks_msec()
			tween.interpolate_method(box, "set_percent_visible", 0.0, 1.0, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			tween.start()

			box.bbcode_text = line[1]
			
			if Global.AUTO_ADVANCE:
				var word_count = len(line[1].split(" "))
				var reading_time = max(1.5, word_count / 225.0 * 60) / Global.TEXT_SPEED
				if line[3]:
					reading_time = 3
				print(word_count, " words, equals ", reading_time, " seconds")
				timer.start(reading_time)
				yield(timer, "timeout")
			else:
				yield(self, "advance")
			
			tween.interpolate_method(box, "set_percent_visible", 1.0, 0.0, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			tween.start()
			yield(tween, "tween_completed")
		elif line[0] == Action.CHOICE:
			current_choice = line[1]
			
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
		elif line[0] == Action.FADEPARTIAL:
			$TweenFade.interpolate_property($FadePartial, "color", Color(0, 0, 0, 0), Color(0, 0, 0, 1), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$TweenFade.start()
			
			yield($TweenFade, "tween_completed")
	
	$TweenFade.interpolate_property($Fade, "color", Color(0, 0, 0, 0), Color(0, 0, 0, 1), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$TweenFade.start()
	
	yield($TweenFade, "tween_completed")
	
	timer.start(1)
	yield(timer, "timeout")
	if not Global.current_config["happy"]:
		Global.happiness[Global.interview_person] = happiness
	Global.interview_finished()

func _on_Choice1Bg_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		choice(0)

func _on_Choice2Bg_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		choice(1)
		
func _input(event):
	if event.is_action_pressed("advance"):
		if OS.get_ticks_msec() - last_line > MINIMUM_WAIT:
			emit_signal("advance")
		
func choice(num):
	if current_choice != 'nellyLoop':
		if num and Global.current_cooldown > 0:
			$Choice/Choice2.bbcode_text = "Sorry, you need to wait a couple of rounds before you can choose these again :("
			return
		if num and Global.productivity <= 20:
			$Choice/Choice2.bbcode_text = "Your productivity is too low to choose this option ;)"
			return
		
		# 0 = bad, 1 = good. innovative & nuanced
		if not num: 
			happiness = clamp(happiness - 30, 0, 100)
			Global.productivity = clamp(Global.productivity + 15, 0, 100)
		else:
			happiness = clamp(happiness + 25, 0, 100)
			Global.productivity = clamp(Global.productivity - 30, 0, 100)
		Global.decrease_cooldown()
		
		if current_choice:
			Global.choices[current_choice] = num
			current_choice = null
	else:
		Global.productivity = (Global.productivity + 50) * 3
		
		$Background.color = gradient.interpolate(1 - ((loop + 1) / 10.0))
		loop += 1
	
	update_values()
	emit_signal("choice_picked")

func update_values():
	$Values/HappyLabel.text = "%s's Happiness: %d%%" % [Global.name(Global.interview_person), happiness]
	var p = "Your Productivity: %d%%" % Global.productivity
	if loop > 3:
		p += "!!!"
	if blink_timer.is_stopped() and loop > 5:
		blink_timer.start(0.1)
	if loop > 6:
		p += " :D"
	$Values/ProdLabel.text = p

func _on_blink_timer_timeout():
	if bright:
		$Values/ProdLabel.add_color_override("font_color", Color(1, 1, 1))
	else:
		$Values/ProdLabel.add_color_override("font_color", Color(0.8, 0.8, 0.8))
	bright = !bright
