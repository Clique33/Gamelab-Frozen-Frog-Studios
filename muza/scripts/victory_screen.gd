extends CanvasLayer
class_name VictoryLayer

@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var victory_label: Label = $HBoxContainer/VictoryLabel

@export var transition_duration : float = 2.0
@export var victory_text_duration : float = 2.0


var _enable_go_back : bool = false

func transition_to_victory_screen():
	var tween : Tween = create_tween()
	tween.tween_property(canvas_modulate,"color",Color(1.0, 1.0, 1.0, 1.0),transition_duration)
	tween.connect("finished",show_victory_screen)
	
func show_victory_screen():
	var tween : Tween = create_tween()
	tween.tween_property(victory_label,"visible_characters",20,victory_text_duration)
	tween.connect("finished",enable_go_back)
	
func enable_go_back():
	_enable_go_back = true

func _input(event: InputEvent) -> void:
	if not _enable_go_back:
		return
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().quit()
