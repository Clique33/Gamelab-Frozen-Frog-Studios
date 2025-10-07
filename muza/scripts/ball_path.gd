extends Node2D
class_name BallPath

@onready var ball_spawner: BallSpawner = $BallSpawner
@onready var path: Path2D = $Path
@onready var begining_checker: Area2D = $BeginingChecker
@onready var ball_checker: BallChecker = $BallChecker

@export_subgroup("Speed")
@export_range(1,100000,1) var speed : int = 50:
	set(value):
		speed = value
		_current_speed = speed
@export_range(1,100000,1) var position_in_path_speed : int = 100
@export_range(1,100000,1) var end_of_level_speed : int = 400
@export_category("Spacing")
@export var spacing_between_spawn : float = 10

var number_of_balls_in_path : int = 0
var _can_spawn : bool = true
var _level_ended : bool = false
var _current_speed : float
var last_index_stopped : int = 1

func _ready() -> void:
	begining_checker.position = path.curve.get_baked_points()[0]
	_current_speed = speed

func _process(_delta: float) -> void:
	if _level_ended:
		end_of_level()
		return 
	if _can_spawn:
		spawn_ball_at_begining()

func _physics_process(delta: float) -> void:
	#working_path(delta)
	if path.get_child_count() == 0:
		return
	
	if path.get_child(-1).progress >= spacing_between_spawn:
		_can_spawn = true
		
	path.get_child(-1).progress += _current_speed*delta
	if  path.get_child(-1).progress_ratio == 1.0:
		handle_ball_reached_the_end(path.get_child(0))
		
	for i in range(len(path.get_children())-2,-1,-1):
		if ((path.get_child(i).progress - path.get_child(i+1).progress) < spacing_between_spawn*.95 or 
		_level_ended):
			path.get_child(i).progress += _current_speed*delta
		if path.get_child(i).progress_ratio == 1.0:
			handle_ball_reached_the_end(path.get_child(i))
	
func working_path(delta : float):
	if path.get_child_count() == 0:
		return
	
	path.get_child(0).progress += _current_speed*delta
	if  path.get_child(0).progress_ratio == 1.0:
		handle_ball_reached_the_end(path.get_child(0))
		
	for i in range(1,len(path.get_children())):
		if ((path.get_child(i-1).progress - path.get_child(i).progress) > spacing_between_spawn or 
		_level_ended):
			path.get_child(i).progress += _current_speed*delta
		if path.get_child(i).progress_ratio == 1.0:
			handle_ball_reached_the_end(path.get_child(i))
	if path.get_child(-1).progress >= spacing_between_spawn:
		_can_spawn = true
	


func end_of_level():
	speed = end_of_level_speed

func create_new_path_follow(after_index : int = -1):
	var path_follow : PathFollow2D = PathFollow2D.new()
	path_follow.connect("child_entered_tree",_on_ball_entered_tree)
	path_follow.loop = false
	if path.get_child_count() == 0:
		path.add_child(path_follow)
	else:
		path.get_child(after_index).add_sibling(path_follow)
	return path_follow

func spawn_ball_at_begining():
	_can_spawn = false
	var path_follow_for_spawned_ball : PathFollow2D = create_new_path_follow()
	var new_ball : Ball = ball_spawner.spawn()
	new_ball.connect("ball_hit",_on_path_ball_hit)
	path_follow_for_spawned_ball.add_child(new_ball)
	handle_new_ball_entered_path(new_ball)

func put_ball_on_path_follow(ball : Ball, path_follow : PathFollow2D, current_progress : float):
	ball.get_parent().remove_child(ball)
	ball.connect("ball_hit",_on_path_ball_hit)
	path_follow.call_deferred("add_child",ball)
	var curr_global_position : Vector2 = ball.global_position
	ball.set_deferred("global_position",curr_global_position)
	path_follow.progress = current_progress

func position_ball_on_path(ball : Ball, at_position : Vector2):
	ball.call_deferred("stop")
	var tween : Tween = create_tween()
	tween.tween_property(ball,"global_position",at_position,0.1)
	tween.chain().tween_property(self,"_current_speed",speed,0.1)

func put_ball_on_path(new_ball : Ball, after_ball : Ball) -> void:
	var path_follow_for_spawned_ball : PathFollow2D
	path_follow_for_spawned_ball = create_new_path_follow(after_ball.get_parent().get_index())
	
	put_ball_on_path_follow(new_ball,
							path_follow_for_spawned_ball,
							after_ball.get_parent().progress)
	
	position_ball_on_path(new_ball, after_ball.global_position)
	handle_new_ball_entered_path(new_ball)

func handle_new_ball_entered_path(new_ball : Ball):
	number_of_balls_in_path = path.get_child_count()
	last_index_stopped += 1
	

func handle_ball_reached_the_end(path_follow : PathFollow2D):
	_level_ended = true
	if path_follow:
		path_follow.queue_free()
	number_of_balls_in_path = path.get_child_count()
	if number_of_balls_in_path == 1:
		path.get_child(0).queue_free()

func _on_path_ball_hit(path_ball : Ball, frog_ball : Ball):
	put_ball_on_path(frog_ball,path_ball)
	_current_speed = position_in_path_speed
	
func _on_ball_entered_tree(node : Node):
	var ball : Ball = node
	if ball.ball_owner == Ball.Owner.PATH:
		return
		
	ball.ball_owner = Ball.Owner.PATH
	var min_max = (ball_checker.indexes_of_same_color_cluster(node.get_parent().get_index()))
	if (ball_checker.is_deletable(min_max)):
		for i in range(min_max[0],min_max[1]+1):
			path.get_child(i).queue_free()
