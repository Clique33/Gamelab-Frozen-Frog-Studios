extends Node
class_name BallSpawner


@export var ball_color : Ball.Colors = Ball.Colors.YELLOW
@export var randomize_color : bool = false
@export var ball_owner : Ball.Owner

var ball_scene : PackedScene = preload("res://scenes/ball.tscn")

##Spawn a random color ball
func spawn(shot_speed : int = 500, initial_rotation : float = 0) -> Ball:
	if randomize_color:
		ball_color = Ball.Colors.values()[randi_range(0,len(Ball.Colors.values())-3)]
	var ball : Ball = ball_scene.instantiate()
	ball.color = ball_color
	ball.ball_owner = ball_owner
	ball.shot_speed = shot_speed
	ball.rotation = initial_rotation
	return ball

func spawn_except(color : Ball.Colors = Ball.Colors.YELLOW):
	var ball : Ball
	while true:
		ball = spawn()
		if ball.color != color: 
			break
	return ball
