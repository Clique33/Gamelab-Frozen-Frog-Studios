extends CanvasLayer
class_name MainMenu

@onready var canvas_modulate: CanvasModulate = $CanvasModulate

@export var fade_duration : float = 1

func _on_new_game_button_pressed() -> void:
	var tween : Tween = create_tween()
	tween.tween_property(canvas_modulate,"color",Color.BLACK,fade_duration)
	tween.connect("finished",transition_to_game)

func transition_to_game():
	get_tree().change_scene_to_file("res://scenes/level1.tscn")

func _on_leave_game_button_pressed() -> void:
	var tween : Tween = create_tween()
	tween.tween_property(canvas_modulate,"color",Color.BLACK,fade_duration)
	tween.connect("finished",quit_game)

func quit_game():
	get_tree().quit()
