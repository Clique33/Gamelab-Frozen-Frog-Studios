extends Node2D
@onready var ball_path: BallPath = $BallPath


func _on_timer_timeout() -> void:
	ball_path._current_speed = ball_path.speed
