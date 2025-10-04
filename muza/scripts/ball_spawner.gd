extends Node
class_name BallSpawner


@export var ball_color : Ball.Colors = Ball.Colors.YELLOW
@export var randomize_color : bool = false
@export var ball_owner : Ball.Owner

var ball_scene : PackedScene = preload("res://scenes/ball.tscn")
var _is_ready_to_start_spawing : bool = false
var _is_on_cooldown : bool = false

##Spawn a random color ball
func spawn() -> Ball:
	if randomize_color:
		ball_color = Ball.Colors.values()[randi_range(0,2)]
	var ball : Ball = ball_scene.instantiate()
	ball.color = ball_color
	ball.ball_owner = ball_owner
	return ball

func spawn_except(color : Ball.Colors = Ball.Colors.YELLOW):
	var ball : Ball
	while true:
		ball = spawn()
		if ball.color != color: 
			break
	return ball
