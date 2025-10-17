extends Node2D

@onready var ball_path: BallPath = $BallPath
@onready var end_mouth: EndMouth = $EndMouth
@onready var victory_layer: EndScreen = $VictoryLayer
@onready var defeat_layer: EndScreen = $DefeatLayer



func _process(delta: float) -> void:
	end_mouth.update_mouth(ball_path.biggest_progress)
	if ball_path.check_if_won():
		victory_layer.transition_to_screen()
		ball_path._game_is_winnable = false
	if ball_path.check_if_lost():
		defeat_layer.transition_to_screen()
		ball_path._game_is_winnable = false


func _on_hud_layer_go_to_menu() -> void:
	pass # Replace with function body.
