extends CanvasLayer
class_name EndScreen

@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer

@export var canvas_modulate: CanvasModulate
@export var message_label: Label
@export var main_menu: PackedScene

@export var transition_duration : float = 2.0
@export var text_duration : float = 2.0
@export var audio_to_be_played : AudioStream


var _enable_go_back : bool = false

func transition_to_screen():
	if audio_stream_player.stream:
		audio_stream_player.play()
	visible = true
	var tween : Tween = create_tween()
	tween.tween_property(canvas_modulate,"color",Color(1.0, 1.0, 1.0, 1.0),transition_duration)
	tween.connect("finished",show_screen)
	
func show_screen():
	var tween : Tween = create_tween()
	tween.tween_property(message_label,"visible_characters",20,text_duration)
	tween.connect("finished",enable_go_back)
	
func enable_go_back():
	_enable_go_back = true

func _input(event: InputEvent) -> void:
	if not _enable_go_back:
		return
	if Input.is_action_just_pressed("shoot"):
		get_tree().change_scene_to_packed(main_menu)
