extends Node2D
class_name EndMouth

@onready var mouth_animated: AnimatedSprite2D = $MouthAnimated

@export var progress : float = 0:
	set(value):
		progress = value
		update_mouth(progress)

func update_mouth(progress : float) -> void:
	if not mouth_animated:
		return
	var number_of_frames : int = -1 + mouth_animated.sprite_frames.get_frame_count(mouth_animated.animation)
	mouth_animated.frame = floor(progress*number_of_frames)
