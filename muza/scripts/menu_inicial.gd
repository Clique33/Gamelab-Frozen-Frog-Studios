extends CanvasLayer
class_name MainMenu

@onready var fade_out_component: FadeOutComponent = $FadeOutComponent


func _on_new_game_button_pressed() -> void:
	fade_out_component.fade_out(transition_to_game)

func transition_to_game():
	get_tree().change_scene_to_file("res://scenes/level1.tscn")

func _on_leave_game_button_pressed() -> void:
	fade_out_component.fade_out(quit_game)

func quit_game():
	get_tree().quit()
