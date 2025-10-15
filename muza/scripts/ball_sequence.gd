extends Node
class_name BallSequence

static var _self_scene : PackedScene = preload("res://scenes/ball_sequence.tscn")

var min_index : int = 0:
	set(value):
		if value > max_index:
			push_error("BallSequence Error: : ",str(value)," is bigger than "+str(max_index))
			return
		if value < 0:
			push_error("BallSequence Error: : ",str(value)," is smaller than 0")
			return
		min_index = value
var max_index : int = 100000000:
	set(value):
		if value < min_index:
			push_error("BallSequence Error: : ",str(value)," is smaller than "+str(min_index))
			return
		if not base_path:
			push_error("BallSequence Error: : There is no base path")
			return
		if value >= base_path.get_child_count():
			push_error("BallSequence Error: : ",str(value)," is bigger than possible")
			return
		min_index = value
var base_path : Path2D

func _ready() -> void:
	is_valid_ball_sequence()


func is_valid_ball_sequence() -> void:
	push_error(not (base_path == null), "BallSequence Error: Parent is not Path2D or does not have parent")
	
func break_sequence_up_to(max_index : int) -> BallSequence:
	if max_index >= base_path.get_child_count()-1:
		return null
	var result : BallSequence = create_ball_sequence(base_path,max_index+1,self.max_index)
	reduce_current_sequence_to(max_index)
	return result

func reduce_current_sequence_to(max_index : int) -> void:
	self.max_index = max_index

static func create_ball_sequence(base_path : Path2D, min_index : int, max_index : int) -> BallSequence:
	var result : BallSequence = _self_scene.instantiate()
	result.base_path = base_path
	result.min_index = min_index
	result.max_index = max_index
	return result

func _to_string() -> String:
	return "BallSequence <%>, from %d to %d" % [name,min_index,max_index]
