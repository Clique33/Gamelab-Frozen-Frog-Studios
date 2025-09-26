extends Node2D
class_name BallPath

@onready var ball_spawner: BallSpawner = $BallSpawner
@onready var path: Path2D = $Path
@onready var begining_checker: Area2D = $BeginingChecker

@export_range(1,100000,1) var speed : int = 50

var _can_spawn : bool = true

func _ready() -> void:
	begining_checker.position = path.curve.get_baked_points()[0]

func _process(delta: float) -> void:
	if _can_spawn:
		put_ball_on_path()

func _physics_process(delta: float) -> void:
	for path_follow in path.get_children():
		path_follow.progress += speed*delta
		if path_follow.progress_ratio == 100:
			handle_ball_reached_the_end(path_follow)

func put_ball_on_path() -> void:
	_can_spawn = false
	var path_follow_for_spawned_ball : PathFollow2D = PathFollow2D.new()
	path.add_child(path_follow_for_spawned_ball)
	path_follow_for_spawned_ball.loop = false
	path_follow_for_spawned_ball.add_child(ball_spawner.spawn())

func handle_ball_reached_the_end(path_follow : PathFollow2D):
	path_follow.queue_free()

func _on_begining_checker_area_exited(area: Area2D) -> void:
	_can_spawn = true
