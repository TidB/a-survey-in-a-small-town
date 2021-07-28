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
	$assignment/RichTextLabel.text = Global.current_config["asgmt"]
	$survey.visible = true
	$survey/bg.color = Color.darkgray
	$assignment.visible = true
	$assignment/bg.color = Color.white
	$evaluation.visible = false
	
func set_evaluation():
	$survey.visible = true
	$survey/bg.color = Color.darkgray
	$assignment.visible = true
	$assignment/bg.color = Color.darkgray
	$evaluation.visible = true
	$evaluation/bg.color = Color.white

func _on_Button_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton && event.pressed):
		Global.evaluation_finished()
