extends Node2D

@onready var path_2d: Path2D = $Path2D
@onready var path_follow_2d: PathFollow2D = $Path2D/PathFollow2D
@onready var path_follow_2d_2: PathFollow2D = $Path2D/PathFollow2D2
@onready var path_follow_2d_3: PathFollow2D = $Path2D/PathFollow2D3
@onready var sprite_2d: Sprite2D = $Path2D/PathFollow2D2/Sprite2D


func _ready() -> void:	
	path_follow_2d.progress = 0.0
	path_follow_2d_2.progress = path_follow_2d_2.get_child(0).texture.get_size().x*sprite_2d.scale.x
	path_follow_2d_3.progress = path_follow_2d_3.get_child(0).texture.get_size().x*sprite_2d.scale.x

func _physics_process(delta: float) -> void:
	for path_follow in path_2d.get_children():
		path_follow.progress += 1
