extends Node
class_name FadeOutComponent

#signal fade_out_finished

@export var duration : float
@export var duration_to_wait_after_fade : float

var _canvas_modulate : CanvasModulate
var _timer : Timer
var _function_to_call : Callable

func _ready() -> void:
	init_canvas_modulate()
	if duration_to_wait_after_fade >= 0.05:
		_timer = Timer.new()
		_timer.wait_time = duration_to_wait_after_fade
		_timer.one_shot = true
		_timer.connect("timeout",_fade_finished)
		add_child(_timer)
	
func init_canvas_modulate() -> void:
	for node in get_parent().get_children():
		if node is CanvasModulate:
			_canvas_modulate = node
			break
	if not _canvas_modulate:
		_canvas_modulate = CanvasModulate.new()
		add_child(_canvas_modulate)


func fade_out(function_to_call_after_fade : Callable = print) -> void:
	_function_to_call = function_to_call_after_fade
	var tween : Tween = create_tween()
	tween.tween_property(_canvas_modulate,"color",Color.BLACK,duration)
	tween.connect("finished",_wait_after_fade)

func _wait_after_fade() -> void:
	if not _timer:
		_fade_finished()
	else:
		_timer.start()

func _fade_finished() -> void:
	_function_to_call.call()
