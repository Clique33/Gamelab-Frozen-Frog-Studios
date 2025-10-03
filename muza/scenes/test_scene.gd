extends Node2D
@onready var ball_path: BallPath = $BallPath


func _on_timer_timeout() -> void:
	print(ball_path.number_of_balls_in_path)
