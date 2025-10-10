extends CharacterBody2D
class_name Ball

enum Colors{YELLOW = 0xffffffff, RED = 0xff1c76ff, GREEN = 0x00ff00ff}
enum Owner{FROG, PATH}

@onready var label: Label = $Label

signal ball_hit(path_ball, frog_ball)
signal tween_finished(ball : Ball)
signal ball_left(path_ball, frog_ball)

@export var shot_speed : int = 500
@export var color : Colors = Colors.YELLOW:
	set(value):
		color = value
		self.modulate = color

var ball_owner : Owner
var _is_shot : bool = false

func _physics_process(_delta: float) -> void:
	label.global_position = global_position + Vector2(15,15)
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

func _on_area_2d_area_entered(area: Area2D) -> void:
	if  not (area.get_parent() is Ball):
		return
	if (self.ball_owner == Owner.FROG or 
		area.get_parent().ball_owner == Owner.PATH) :
		return
	ball_hit.emit(self,area.get_parent())

func _on_area_2d_area_exited(area: Area2D) -> void:
	if  not (area.get_parent() is Ball):
		return
	if (self.ball_owner == Owner.FROG or 
		area.get_parent().ball_owner == Owner.FROG) :
		return
	ball_left.emit(self,area.get_parent())
	
func tween_finished_emitter():
	emit_signal("tween_finished",self)
