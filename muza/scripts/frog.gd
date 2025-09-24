extends Node2D
class_name Frog

@onready var ready_ball_position: Node2D = $ReadyBallPosition
@onready var stand_by_ball_position: Node2D = $StandByBallPosition
@onready var ball_spawner: BallSpawner = $BallSpawner

func _ready() -> void:
	ready_ball_position.add_child(ball_spawner.spawn())
	stand_by_ball_position.add_child(ball_spawner.spawn_except(ready_ball_position.get_child(0).color))

func _physics_process(delta: float) -> void:
	look_at(get_global_mouse_position())
	if Input.is_action_just_released("ui_accept"):
		swap_balls()

func swap_balls() -> void:
	var mouth_ball : Ball = ready_ball_position.get_child(0)
	var other_ball : Ball = stand_by_ball_position.get_child(0)
	ready_ball_position.remove_child(mouth_ball)
	stand_by_ball_position.add_child(mouth_ball)
	stand_by_ball_position.remove_child(other_ball)
	ready_ball_position.add_child(other_ball)
	mouth_ball.position = Vector2.ZERO

	other_ball.position = Vector2.ZERO
