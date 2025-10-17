extends CanvasLayer
class_name MainMenu

@onready var fade_out_component: FadeOutComponent = $FadeOutComponent
@onready var button_pressed_audio_player: AudioStreamPlayer2D = $SoundEffects/ButtonPressedAudioPlayer


func _on_new_game_button_pressed() -> void:
	fade_out_component.fade_out(transition_to_game)
	button_pressed_audio_player.play()

func transition_to_game():
	get_tree().change_scene_to_file("res://scenes/level1.tscn")

func _on_leave_game_button_pressed() -> void:
	fade_out_component.fade_out(quit_game)
	button_pressed_audio_player.play()

func quit_game():
	get_tree().quit()
