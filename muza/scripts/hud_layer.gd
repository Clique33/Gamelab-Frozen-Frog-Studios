extends CanvasLayer
class_name HUDLayer

signal go_to_menu

@onready var end_game_progress_bar: TextureProgressBar = $Control/EndGameProgressBar
@onready var end_game_arrived_bar: TextureRect = $Control/EndGameArrivedBar
@onready var end_of_level_audio_player: AudioStreamPlayer2D = $Control/SoudEffects/EndOfLevelAudioPlayer
@onready var button_pressed_audio_player: AudioStreamPlayer2D = $Control/SoudEffects/ButtonPressedAudioPlayer

@export var total_number_of_balls : int = 100:
	set(value):
		total_number_of_balls = value
		end_game_progress_bar.max_value = total_number_of_balls

func increment_progress_of_game() -> void:
	update_progress_of_game(end_game_progress_bar.value+1)

func update_progress_of_game(value : int) -> void:
	end_game_progress_bar.value = value
	if end_game_progress_bar.value == end_game_progress_bar.max_value:
		end_game_progress_bar.visible = false
		end_game_arrived_bar.visible = true
		end_of_level_audio_player.play()

func _on_menu_button_pressed() -> void:
	emit_signal("go_to_menu")
	button_pressed_audio_player.play()
