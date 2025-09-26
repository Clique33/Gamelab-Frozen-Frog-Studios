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
	if Input.is_action_just_released("swap_balls"):
		swap_balls()
	if Input.is_action_just_released("shoot"):
		shoot(get_global_mouse_position())


func give_ball(from_node : Node, to_node : Node) -> void:
	var ball : Ball = from_node.get_child(0)
	from_node.remove_child(ball)
	to_node.add_child(ball)

func swap_balls() -> void:
	give_ball(ready_ball_position,stand_by_ball_position)
	give_ball(stand_by_ball_position,ready_ball_position)

	
func shoot(at_point : Vector2) -> void:
	var mouth_ball : Ball = ready_ball_position.get_child(0)
	var original_position : Vector2 = mouth_ball.global_position
	ready_ball_position.remove_child(mouth_ball)
	get_parent().add_child(mouth_ball)
	mouth_ball.global_position = original_position
	mouth_ball.be_shot(at_point)
	
	give_ball(stand_by_ball_position,ready_ball_position)
	stand_by_ball_position.add_child(ball_spawner.spawn_except(ready_ball_position.get_child(0).color))
