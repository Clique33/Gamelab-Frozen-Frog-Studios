extends Node
class_name BallSpawner

signal spawner_reached_end

@export var ball_color : Ball.Colors = Ball.Colors.YELLOW
@export var randomize_color : bool = false
@export var ball_owner : Ball.Owner
@export var max_spawned_balls : int = 100000

var ball_scene : PackedScene = preload("res://scenes/ball.tscn")

var _total_spawned_balls : int = 0

##Spawn a random color ball
func spawn(shot_speed : int = 500) -> Ball:
	if _total_spawned_balls >= max_spawned_balls:
		return
	if _total_spawned_balls == max_spawned_balls-1:
		spawner_reached_end.emit()
	
	_total_spawned_balls += 1 
	
	if randomize_color:
		ball_color = Ball.Colors.values()[randi_range(0,2)]
	var ball : Ball = ball_scene.instantiate()
	ball.color = ball_color
	ball.ball_owner = ball_owner
	ball.shot_speed = shot_speed
	return ball

func spawn_except(color : Ball.Colors = Ball.Colors.YELLOW):
	var ball : Ball
	while true:
		ball = spawn()
		if ball.color != color: 
			break
	return ball
