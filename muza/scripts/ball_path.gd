extends Node2D
class_name BallPath

@onready var ball_spawner: BallSpawner = $BallSpawner
@onready var path: Path2D = $Path
@onready var begining_checker: Area2D = $BeginingChecker

@export_range(1,100000,1) var speed : int = 50
@export_range(1,100000,1) var end_of_level_speed : int = 400

var number_of_balls_in_path : int = 0
var _can_spawn : bool = true
var _level_ended : bool = false

func _ready() -> void:
	begining_checker.position = path.curve.get_baked_points()[0]

func _process(delta: float) -> void:
	if _level_ended:
		end_of_level()
		return 
	if _can_spawn:
		put_ball_on_path()

func _physics_process(delta: float) -> void:
	for path_follow in path.get_children():
		path_follow.progress += speed*delta
		if path_follow.progress_ratio == 1.0:
			handle_ball_reached_the_end(path_follow)

func end_of_level():
	speed = end_of_level_speed

func put_ball_on_path() -> void:
	_can_spawn = false
	var path_follow_for_spawned_ball : PathFollow2D = PathFollow2D.new()
	path.add_child(path_follow_for_spawned_ball)
	path_follow_for_spawned_ball.loop = false
	path_follow_for_spawned_ball.add_child(ball_spawner.spawn())
	number_of_balls_in_path = path.get_child_count()

func handle_ball_reached_the_end(path_follow : PathFollow2D):
	_level_ended = true
	path_follow.queue_free()
	number_of_balls_in_path = path.get_child_count()
	if number_of_balls_in_path == 1:
		print(path.get_child_count())

func _on_begining_checker_area_exited(area: Area2D) -> void:
	if area.get_parent().ball_owner != Ball.Owner.PATH:
		return
	_can_spawn = true
