extends Node2D

@onready var ball_path: BallPath = $BallPath
@onready var end_mouth: EndMouth = $EndMouth
@onready var victory_layer: VictoryLayer = $VictoryLayer



func _process(delta: float) -> void:
	end_mouth.update_mouth(ball_path.biggest_progress)
	if ball_path.check_if_won():
		victory_layer.transition_to_victory_screen()
		ball_path._game_is_winnable = false
