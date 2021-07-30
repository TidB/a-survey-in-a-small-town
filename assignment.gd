extends Node2D


func _ready():
	$Button/CollisionPolygon2D.polygon = $Button/Polygon2D.polygon
	if Global.report_state == Global.ReportState.Assignment:
		set_assignment()
	elif Global.report_state == Global.ReportState.Evaluation:
		set_evaluation()
	elif Global.report_state == Global.ReportState.Survey:
		set_survey()

func set_survey():
	$survey.visible = true
	$survey/bg.color = Color.white
	$assignment.visible = false
	$evaluation.visible = false
	
func set_assignment():
	$assignment/RichTextLabel.text = Global.current_config['asgmt']
	$survey.visible = true
	$survey/bg.color = Color.darkgray
	$assignment.visible = true
	$assignment/bg.color = Color.white
	$evaluation.visible = false
	
func set_evaluation():
	var text = '\n' + Global.current_config['eval'] + "\n\n"
	
	if Global.current_step + 1 < Global.timelines:
		if Global.productivity <= 40:
			Global.reset_cooldown()
			text += "Your productivity was a tad low, so in the next few choices you'll have to pick the option that's better (for us) ;)"
		else:
			text += "Nice job keeping productivity high!! :D"
		
		text += "\n\n"
		
		if Global.average_happiness() <= 50:
			text += "Aww, the interviewees were kinda sad :'("
		else:
			text += "Wow!! The interviewees were happy (enough)! Remember that this is not (y)our goal though ;)"
	else:
		$PostIt.visible = true
	
	$evaluation/RichTextLabel.text = text
	$survey.visible = true
	$survey/bg.color = Color.darkgray
	$assignment.visible = true
	$assignment/bg.color = Color.darkgray
	$evaluation.visible = true
	$evaluation/bg.color = Color.white

func _on_Button_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		Global.evaluation_finished()
