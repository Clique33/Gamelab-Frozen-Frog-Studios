extends CharacterBody2D
class_name Ball

enum Colors{YELLOW = 0xffffffff, RED = 0xff1c76ff, GREEN = 0x00ff00ff}
enum Owner{FROG, PATH}

@export var shot_speed : int = 500
@export var color : Colors = Colors.YELLOW:
	set(value):
		color = value
		self.modulate = color

var ball_owner : Owner
var _is_shot : bool = false

func _physics_process(delta: float) -> void:
	move_and_slide()

func be_shot(at_point : Vector2) -> void:
	if _is_shot:
		return
	var direction_shot : Vector2 = (at_point-global_position).normalized()
	_is_shot = true
	velocity = direction_shot*shot_speed

func stop() -> void:
	_is_shot = false
	velocity = Vector2.ZERO
	
