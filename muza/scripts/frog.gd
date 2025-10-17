extends Node2D
class_name Frog

@onready var ready_ball_position: Node2D = $ReadyBallPosition
@onready var stand_by_ball_position: Node2D = $StandByBallPosition
@onready var ball_spawner: BallSpawner = $BallSpawner
@onready var shot_cooldown_timer: Timer = $ShotCooldownTimer
@onready var frog_animated: AnimatedSprite2D = $FrogAnimated
@onready var gem_animated: AnimatedSprite2D = $GemAnimated
@onready var shot_audio_player: AudioStreamPlayer2D = $SoundEffects/ShotAudioPlayer
@onready var swap_balls_audio_player: AudioStreamPlayer2D = $SoundEffects/SwapBallsAudioPlayer


@export_range(100,10000,50) var shot_speed : int
@export_range(0.05,10,0.01) var shot_cooldown : float = 0.001:
	set(value):
		shot_cooldown = value
		if shot_cooldown_timer:
			shot_cooldown_timer.wait_time = shot_cooldown

func _ready() -> void:
	var ball : Ball = ball_spawner.spawn(shot_speed)
	ready_ball_position.add_child(ball)
	ball = ball_spawner.spawn(shot_speed)
	ball.visible = false
	stand_by_ball_position.add_child(ball)
	gem_animated.play(Ball._colors_to_animations[ball.color])
	shot_cooldown_timer.wait_time = shot_cooldown

func _physics_process(_delta: float) -> void:
	look_at(get_global_mouse_position())

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("swap_balls"):
		swap_balls()
	if event.is_action_released("shoot") and shot_cooldown_timer.is_stopped():
			shoot(get_global_mouse_position())

func give_ball(from_node : Node, to_node : Node) -> void:
	var ball : Ball = from_node.get_child(0)
	from_node.remove_child(ball)
	to_node.add_child(ball)

func swap_balls() -> void:
	give_ball(ready_ball_position,stand_by_ball_position)
	give_ball(stand_by_ball_position,ready_ball_position)
	ready_ball_position.get_child(0).visible = true
	stand_by_ball_position.get_child(0).visible = false
	gem_animated.play(Ball._colors_to_animations[stand_by_ball_position.get_child(0).color])
	swap_balls_audio_player.play()

func shoot(at_point : Vector2) -> void:
	var mouth_ball : Ball = ready_ball_position.get_child(0)
	var original_position : Vector2 = mouth_ball.global_position
	ready_ball_position.remove_child(mouth_ball)
	get_parent().add_child(mouth_ball)
	mouth_ball.global_position = original_position
	mouth_ball.be_shot(at_point)
	frog_animated.play("default")
	shot_cooldown_timer.start()
	give_ball(stand_by_ball_position,ready_ball_position)
	ready_ball_position.get_child(0).visible = true
	var ball : Ball = ball_spawner.spawn(shot_speed)
	ball.visible = false
	stand_by_ball_position.add_child(ball)
	gem_animated.play(Ball._colors_to_animations[ball.color])
	shot_audio_player.play()
