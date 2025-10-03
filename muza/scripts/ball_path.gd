extends Node2D
class_name BallPath

@onready var ball_spawner: BallSpawner = $BallSpawner
@onready var path: Path2D = $Path
@onready var begining_checker: Area2D = $BeginingChecker

@export_range(1,100000,1) var speed : int = 50:
	set(value):
		speed = value
		_current_speed = speed
@export_range(1,100000,1) var end_of_level_speed : int = 400

var number_of_balls_in_path : int = 0
var _can_spawn : bool = true
var _level_ended : bool = false
var _current_speed : float
var last_index_stopped : int = 1

func _ready() -> void:
	begining_checker.position = path.curve.get_baked_points()[0]
	_current_speed = speed

func _process(delta: float) -> void:
	if _level_ended:
		end_of_level()
		return 
	if _can_spawn:
		put_ball_on_path()

func _physics_process(delta: float) -> void:
	var path_follow : PathFollow2D
	for i in len(path.get_children()):
		path_follow = path.get_child(i)
		if i < last_index_stopped:
			path_follow.progress += _current_speed*delta
		if path_follow.progress_ratio == 1.0:
			handle_ball_reached_the_end(path_follow)

func end_of_level():
	speed = end_of_level_speed

func put_ball_on_path(new_ball : Ball = null, at_progress : float = 0, at_point : Vector2 = Vector2.ZERO) -> void:
	_can_spawn = false
	var path_follow_for_spawned_ball : PathFollow2D = PathFollow2D.new()
	path.add_child(path_follow_for_spawned_ball)
	path_follow_for_spawned_ball.loop = false
	
	if new_ball == null:
		new_ball = ball_spawner.spawn()
		new_ball.connect("ball_hit",_on_path_ball_hit)
		new_ball.connect("ball_left",_on_path_ball_left)
		path_follow_for_spawned_ball.add_child(new_ball)
	else:
		var curr_global_position : Vector2 = new_ball.global_position
		new_ball.get_parent().remove_child(new_ball)
		new_ball.ball_owner = Ball.Owner.PATH
		new_ball.connect("ball_hit",_on_path_ball_hit)
		path_follow_for_spawned_ball.call_deferred("add_child",new_ball)
		new_ball.set_deferred("global_position",curr_global_position)
		new_ball.call_deferred("stop")
		create_tween().tween_property(new_ball,"global_position",at_point,0.2)
		#new_ball.set_deferred("position",Vector2.ZERO)
		#path_follow_for_spawned_ball.add_child(new_ball)
		path_follow_for_spawned_ball.progress = at_progress
		
	number_of_balls_in_path = path.get_child_count()
	last_index_stopped += 1

func handle_ball_reached_the_end(path_follow : PathFollow2D):
	_level_ended = true
	path_follow.queue_free()
	number_of_balls_in_path = path.get_child_count()
	if number_of_balls_in_path == 1:
		print(path.get_child(0).get_child(0))

func stop(from_index : int) -> void:
	last_index_stopped = from_index

func start() -> void:
	last_index_stopped = number_of_balls_in_path

func _on_begining_checker_area_exited(area: Area2D) -> void:
	if area.get_parent().ball_owner == Ball.Owner.PATH:
		_can_spawn = true
		return
	if area.get_parent().ball_owner == Ball.Owner.FROG:
		area.get_parent().queue_free()
		return

func _on_path_ball_hit(path_ball : Ball, frog_ball : Ball):
	put_ball_on_path(frog_ball,path_ball.get_parent().progress,path_ball.global_position)
	stop(path_ball.get_parent().get_index()+1)
	
func _on_path_ball_left(path_ball : Ball, frog_ball : Ball):
	start()
