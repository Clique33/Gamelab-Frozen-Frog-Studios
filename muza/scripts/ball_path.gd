extends Node2D
class_name BallPath

@onready var ball_spawner: BallSpawner = $BallSpawner
@onready var path: Path2D = $Path
@onready var begining_checker: Area2D = $BeginingChecker
@onready var ball_checker: BallChecker = $BallChecker
@onready var begin_of_level_timer: Timer = $BeginOfLevelTimer

@export var begining_time : float = 1.0
@export_subgroup("Speed")
@export_range(1,100000,1) var speed : int = 50:
	set(value):
		speed = value
		_current_speed = speed
@export_range(1,100000,1) var position_in_path_speed : int = 100
@export_range(1,100000,1) var begin_of_level_speed : int = 300
@export_range(1,100000,1) var end_of_level_speed : int = 400
@export_category("Spacing")
@export var spacing_between_spawn : float = 10

var number_of_balls_in_path : int = 0
var _can_spawn : bool = true
var _level_ended : bool = false
var _current_speed : float
var _last_connected_ball_indexes : Array[int] = [0]
var _last_length_connected_ball_indexes : int = 1

func _ready() -> void:
	begin_of_level_timer.wait_time = begining_time
	begin_of_level_timer.start()
	ball_checker.spacing_between_balls = spacing_between_spawn
	begining_checker.position = path.curve.get_baked_points()[0]
	_current_speed = begin_of_level_speed

func _process(_delta: float) -> void:
	if _level_ended:
		end_of_level()
		return 
	if _can_spawn:
		spawn_ball_at_begining()

func _physics_process(delta: float) -> void:
	move_initial_connected_balls(delta)
	move_back_combo(delta)

func move_back_combo(delta):
	pass

func move_initial_connected_balls(delta : float):
	if path.get_child_count() == 0:
		return
		
	var path_follow : PathFollow2D = path.get_child(_last_connected_ball_indexes[0])
	
	path_follow.progress += _current_speed*delta
	if  path_follow.progress_ratio == 1.0:
		handle_ball_reached_the_end(path_follow)
		
	for i in range(_last_connected_ball_indexes[0]+1,len(path.get_children())):
		path_follow = path.get_child(i)
		if (path.get_child(i-1).progress - path_follow.progress) > spacing_between_spawn or _level_ended:
			path_follow.progress = path.get_child(i-1).progress - spacing_between_spawn
		if path_follow.progress_ratio == 1.0:
			handle_ball_reached_the_end(path_follow)
	if path.get_child(-1).progress >= spacing_between_spawn:
		_can_spawn = true
	update_last_connected_indexes()

func update_last_connected_indexes(end_index : int = (len(path.get_children())-1)) -> void:
	if end_index == (len(path.get_children())-1):
		_last_length_connected_ball_indexes = len(_last_connected_ball_indexes)
		_last_connected_ball_indexes = []
	for i in range(end_index,0,-1):
		if (path.get_child(i-1).progress - path.get_child(i).progress) > spacing_between_spawn*1.02:
			_last_connected_ball_indexes.append(i)
			update_last_connected_indexes(i-1)
			return
	_last_connected_ball_indexes.append(0)

func end_of_level():
	speed = end_of_level_speed

func create_new_path_follow(after_index : int = -1, progress : float = 0):
	var path_follow : PathFollow2D = PathFollow2D.new()
	path_follow.connect("child_entered_tree",_on_ball_entered_tree)
	path_follow.connect("child_exiting_tree",_on_ball_exiting_tree)
	path_follow.connect("tree_exited",_on_path_child_exiting_tree)
	path_follow.loop = false
	path_follow.progress = progress
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

func put_ball_on_path_follow(ball : Ball, path_follow : PathFollow2D):
	ball.get_parent().remove_child(ball)
	ball.connect("ball_hit",_on_path_ball_hit)
	path_follow.call_deferred("add_child",ball)

func position_ball_on_path(ball : Ball, at_position : Vector2):
	var curr_global_position : Vector2 = ball.global_position
	ball.set_deferred("global_position",curr_global_position)
	ball.call_deferred("stop")
	var tween : Tween = create_tween()
	tween.tween_property(ball,"global_position",at_position,0.2)
	tween.connect("finished",ball.tween_finished_emitter)
	create_tween().tween_property(self,"_current_speed",speed,0.2)
	

func put_ball_on_path(new_ball : Ball, after_ball : Ball) -> void:
	var path_follow_for_spawned_ball : PathFollow2D
	path_follow_for_spawned_ball = (
		create_new_path_follow(
			after_ball.get_parent().get_index(),
			after_ball.get_parent().progress
		)
	)
	put_ball_on_path_follow(new_ball, path_follow_for_spawned_ball)
	position_ball_on_path(new_ball, after_ball.global_position)

func handle_destroy_balls(ball : Ball):
	var min_max = (ball_checker.indexes_of_same_color_cluster(ball.get_parent().get_index()))
	if (ball_checker.is_deletable(min_max)):
		#print(min_max)
		for i in range(min_max[0],min_max[1]+1):
			path.get_child(i).queue_free()

func handle_ball_reached_the_end(path_follow : PathFollow2D):
	_level_ended = true
	if path_follow:
		path_follow.queue_free()
	number_of_balls_in_path = path.get_child_count()
	if number_of_balls_in_path == 1:
		path.get_child(0).queue_free()

func _on_path_ball_hit(path_ball : Ball, frog_ball : Ball):
	frog_ball.connect("tween_finished",_on_ball_positioned)
	put_ball_on_path(frog_ball,path_ball)
	_current_speed = position_in_path_speed

func _on_ball_entered_tree(node : Node):
	var ball : Ball = node
	if ball.ball_owner == Ball.Owner.PATH:
		return
	
	ball.ball_owner = Ball.Owner.PATH

func _on_ball_exiting_tree(node : Node):
	#print("_on_ball_exiting_tree")
	pass

func _on_path_child_exiting_tree() -> void:
	update_last_connected_indexes()

func _on_begin_of_level_timer_timeout() -> void:
	_current_speed = speed

func _on_ball_positioned(ball : Ball) -> void:
	handle_destroy_balls(ball)
