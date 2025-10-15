extends Node2D

@onready var ball_path: BallPath = $BallPath
@onready var end_mouth: EndMouth = $EndMouth



func _process(delta: float) -> void:
	end_mouth.update_mouth(ball_path.biggest_progress)
