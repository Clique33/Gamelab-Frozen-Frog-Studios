extends Node2D
class_name BallPath

signal spawned_ball

@export var curve : Curve2D
@export var begining_time : float = 1.0
@export_subgroup("Speed")
@export_range(1,100000,1) var speed : int = 50:
	set(value):
		speed = value
		_current_speed = speed
@export_range(1,100000,1) var position_in_path_speed : int = 100
@export_range(1,100000,1) var begin_of_level_speed : int = 300
@export_range(1,100000,1) var end_of_level_speed : int = 400
@export_category("Spacing")
@export var spacing_between_spawn : float = 10
@export var max_number_of_spawned_balls : int = 100 

var biggest_progress : float = 0
var number_of_balls_in_path : int = 0
var _can_spawn : bool = true
var _level_lost : bool = false
var _game_is_winnable : bool = false
var _current_speed : float
var _biggest_connected_ball_indexes : Array[int] = [0]
var _number_of_spawned_balls : int = 0
var _previously_biggest_connected_ball_indexes : Array[int]
var _ball_hit_players : Array[AudioStreamPlayer2D]

@onready var ball_spawner: BallSpawner = $BallSpawner
@onready var path: Path2D = $Path
@onready var ghost_path: Path2D = $GhostPath
@onready var begining_checker: Area2D = $BeginingChecker
@onready var ball_checker: BallChecker = $BallChecker
@onready var begin_of_level_timer: Timer = $BeginOfLevelTimer
@onready var ball_hit_1_player: AudioStreamPlayer2D = $SoundEffects/BallHit1Player
@onready var ball_hit_2_player: AudioStreamPlayer2D = $SoundEffects/BallHit2Player
@onready var level_begin_chant_audio_player: AudioStreamPlayer2D = $"../SoundEffects/LevelBeginChantAudioPlayer"
@onready var level_begin_rolling_audio_player: AudioStreamPlayer2D = $"../SoundEffects/LevelBeginRollingAudioPlayer"
@onready var balls_destroyed_audio_player: AudioStreamPlayer2D = $"../SoundEffects/BallsDestroyedAudioPlayer"


func _ready() -> void:
	level_begin_chant_audio_player.play()
	level_begin_rolling_audio_player.play()
	_ball_hit_players = [ball_hit_1_player,ball_hit_2_player]
	path.curve = curve
	begin_of_level_timer.wait_time = begining_time
	begin_of_level_timer.start()
	ball_checker.spacing_between_balls = spacing_between_spawn
	begining_checker.position = path.curve.get_baked_points()[0]
	_current_speed = begin_of_level_speed
	ghost_path.curve = curve
	spawn_ball_at_ghost_path()

func _process(delta: float) -> void:
	update_progress_towards_defeat()
	if _level_lost:
		end_of_level()
	spawn_ball_at_begining()
	update_last_connected_indexes()
	move_last_ball(delta)
	move_initial_connected_balls()
	update_last_connected_indexes()
	fix_positions_of_balls()
	move_back_combo(delta)
	for i in range(1,len(_biggest_connected_ball_indexes)):
		move_initial_connected_balls(i,false)


func fix_positions_of_balls():
	pass


func spawn_ball_at_ghost_path():
	var path_follow_for_spawned_ball : PathFollow2D = create_new_path_follow(-1,0,ghost_path)
	var new_ball : Ball = ball_spawner.spawn(500,-PI/2)
	new_ball.color = Ball.Colors.SILVER
	path_follow_for_spawned_ball.add_child.call_deferred(new_ball)
	new_ball.set_deferred("global_position",path.curve.get_baked_points()[0])


func check_if_won() -> bool:
	if _game_is_winnable and (not _level_lost) and path.get_child_count() == 0:
		return true
	return false

func check_if_lost() -> bool:
	if _game_is_winnable and _level_lost and path.get_child_count() == 0:
		return true
	return false

func update_progress_towards_defeat() -> void:
	if path.get_child_count() == 0:
		biggest_progress = 0
		return 
	
	biggest_progress = path.get_child(0).progress_ratio

func move_last_ball(delta : float, index_last_ball : int = -1, forward : bool = true) -> void:
	if path.get_child_count() == 0:
		return
	if index_last_ball == -1:
		index_last_ball = _biggest_connected_ball_indexes[0]
	
	var path_follow : PathFollow2D = path.get_child(index_last_ball)
	if forward:
		path_follow.progress += _current_speed*delta
	else:
		path_follow.progress -= _current_speed*3*delta
	if  path_follow.progress_ratio == 1.0:
		handle_ball_reached_the_end(path_follow)
	
func move_back_combo(delta):
	if(len(_biggest_connected_ball_indexes) < 2):
		return 
	for i in len(_biggest_connected_ball_indexes)-1:
		if (ball_checker.is_combo(_biggest_connected_ball_indexes[i])):
			move_last_ball(delta,_biggest_connected_ball_indexes[i+1],false)

func move_backwards(index : int, delta : float):
	for j in range(_biggest_connected_ball_indexes[index]-2,_biggest_connected_ball_indexes[index+1]-1,-1):
		if (path.get_child(j-1).progress - path.get_child(j).progress) > spacing_between_spawn:
			path.get_child(j).progress = path.get_child(j-1).progress - spacing_between_spawn

func move_other_connected_balls():
	if len(_biggest_connected_ball_indexes) < 2:
		return
		
	var path_follow : PathFollow2D
		
	for i in range(1,len(_biggest_connected_ball_indexes)):
		for j in range(_biggest_connected_ball_indexes[i]+1,_biggest_connected_ball_indexes[i-1]):
			path_follow = path.get_child(j)
			if (path.get_child(j-1).progress - path_follow.progress) < spacing_between_spawn:
				path_follow.progress = path.get_child(j-1).progress - spacing_between_spawn
				pass
			if path_follow.progress_ratio == 1.0:
				handle_ball_reached_the_end(path_follow)

func move_initial_connected_balls(index : int = 0, forward : bool = true):
	if path.get_child_count() == 0:
		return
		
	var path_follow : PathFollow2D
	var first_index : int = _biggest_connected_ball_indexes[index]
	var last_index : int = len(path.get_children())
	
	if index > 0:
		last_index = _biggest_connected_ball_indexes[index-1]
	
	if forward:
		for i in range(first_index+1,last_index):
			path_follow = path.get_child(i)
			if (path.get_child(i-1).progress - path_follow.progress) > spacing_between_spawn or _level_lost:
				path_follow.progress = path.get_child(i-1).progress - spacing_between_spawn
			if path_follow.progress_ratio == 1.0:
				handle_ball_reached_the_end(path_follow)
	else:
		for i in range(first_index+1,last_index):
			path_follow = path.get_child(i)
			if (path.get_child(i-1).progress - path_follow.progress) < spacing_between_spawn or _level_lost:
				path_follow.progress = path.get_child(i-1).progress - spacing_between_spawn
			if path_follow.progress_ratio == 1.0:
				handle_ball_reached_the_end(path_follow)
		
	if path.get_child(-1).progress >= spacing_between_spawn:
		_can_spawn = true

func update_last_connected_indexes(end_index : int = (len(path.get_children())-1)) -> void:
	if end_index == (len(path.get_children())-1):
		_previously_biggest_connected_ball_indexes =_biggest_connected_ball_indexes.duplicate()
		_biggest_connected_ball_indexes = []
	for i in range(end_index,0,-1):
		if (path.get_child(i-1).progress - path.get_child(i).progress) > spacing_between_spawn*1.02:
			_biggest_connected_ball_indexes.append(i)
			update_last_connected_indexes(i-1)
			return
	_biggest_connected_ball_indexes.append(0)
	
	if _previously_biggest_connected_ball_indexes != _previously_biggest_connected_ball_indexes:
		print("_biggest_connected_ball_indexes : ",_biggest_connected_ball_indexes)
		print("_previously_biggest_connected_ball_indexes : ",_previously_biggest_connected_ball_indexes)
		
	for index in _biggest_connected_ball_indexes:
		if index in _previously_biggest_connected_ball_indexes:
			_previously_biggest_connected_ball_indexes.erase(index)
	
	if not _previously_biggest_connected_ball_indexes.is_empty():
		_on_ball_positioned(path.get_child(0).get_child(0))
	

func end_of_level():
	speed = end_of_level_speed

func create_new_path_follow(after_index : int = -1, progress : float = 0, path : Path2D = self.path):
	
	var path_follow : PathFollow2D = PathFollow2D.new()
	path_follow.connect("child_entered_tree",_on_ball_entered_tree)
	path_follow.loop = false
	path_follow.progress = progress
	
	if path.get_child_count() == 0:
		path.add_child(path_follow)
	else:
		path.get_child(after_index).add_sibling(path_follow)
	return path_follow

func spawn_ball_at_begining():
	if not _can_spawn:
		return
	if _number_of_spawned_balls >= max_number_of_spawned_balls:
		return
	_can_spawn = false
	_number_of_spawned_balls += 1
	var path_follow_for_spawned_ball : PathFollow2D = create_new_path_follow()
	var new_ball : Ball = ball_spawner.spawn(500,-PI/2)
	new_ball.connect("ball_hit",_on_path_ball_hit)
	path_follow_for_spawned_ball.add_child(new_ball)
	spawned_ball.emit()

func put_ball_on_path_follow(ball : Ball, path_follow : PathFollow2D):
	ball.get_parent().remove_child(ball)
	ball.connect("ball_hit",_on_path_ball_hit)
	path_follow.call_deferred("add_child",ball)

func position_ball_on_path(ball : Ball, at_position : Vector2):
	var curr_global_position : Vector2 = ball.global_position
	ball.set_deferred("global_position",curr_global_position)
	ball.call_deferred("stop")
	at_position = ghost_path.get_child(0).get_child(0).global_position
	var tween : Tween = create_tween()
	tween.tween_property(ball,"global_position",at_position,0.4)
	tween.connect("finished",ball.tween_finished_emitter)
	create_tween().tween_property(self,"_current_speed",speed,0.4)

func put_ball_on_path(new_ball : Ball, after_ball : Ball) -> void:
	var path_follow_for_spawned_ball : PathFollow2D
	path_follow_for_spawned_ball = (
		create_new_path_follow(
			after_ball.get_parent().get_index(),
			after_ball.get_parent().progress
		)
	)
	put_ball_on_path_follow(new_ball, path_follow_for_spawned_ball)
	print(ghost_path.get_children())
	ghost_path.get_child(0).progress = after_ball.get_parent().progress
	position_ball_on_path(new_ball, ghost_path.get_child(0).get_child(0).global_position)

func handle_destroy_balls(ball : Ball):
	var min_max = (ball_checker.indexes_of_same_color_cluster(ball.get_parent().get_index()))
	if (ball_checker.is_deletable(min_max)):
		for i in range(min_max[0],min_max[1]+1):
			path.get_child(i).queue_free()
		balls_destroyed_audio_player.play()

func handle_ball_reached_the_end(path_follow : PathFollow2D):
	_level_lost = true
	if path_follow:
		path_follow.queue_free()
	number_of_balls_in_path = path.get_child_count()
	if number_of_balls_in_path == 1:
		path.get_child(0).queue_free()

func _on_path_ball_hit(path_ball : Ball, frog_ball : Ball):
	frog_ball.connect("tween_finished",_on_ball_positioned)
	put_ball_on_path(frog_ball,path_ball)
	frog_ball.label.text = "hit"
	path_ball.label.text = "hit"
	_current_speed = position_in_path_speed
	_ball_hit_players[randi_range(0,len(_ball_hit_players)-1)].play()

func _on_ball_entered_tree(node : Node):
	var ball : Ball = node
	if ball.ball_owner == Ball.Owner.PATH:
		return
	ball.ball_owner = Ball.Owner.PATH

func _on_begin_of_level_timer_timeout() -> void:
	_current_speed = speed
	_game_is_winnable = true

func _on_ball_positioned(ball : Ball) -> void:
	handle_destroy_balls(ball)
	update_last_connected_indexes()
	move_other_connected_balls()
