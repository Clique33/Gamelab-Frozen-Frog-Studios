extends CharacterBody2D
class_name Mario

@onready var sprite_2d: Sprite2D = $Sprite2D


@export var speed : int = 30

func _process(delta: float) -> void:
	var x : float
	if Input.is_action_just_pressed("walk_right"):
		velocity = Vector2(1,0)*speed
		sprite_2d.flip_h = false
	if Input.is_action_just_pressed("walk_left"):
		velocity = Vector2(-1,0)*speed
		sprite_2d.flip_h = true
	if (Input.is_action_just_released("walk_right") or 
		Input.is_action_just_released("walk_left")):
		velocity = Vector2(0,0)
	
	move_and_slide()
