extends Node
class_name BallChecker

@export var path : Path2D ##Path whose children are Pathfollows of Balls
@export var spacing_between_balls : float 

##Returns the minimum and maximum indexes of the cluster of same color balls in 
##which 'index' is part of.
func indexes_of_same_color_cluster(index : int) -> Array[int]:
	assert(path.get_child_count() > index,"Path does not contain "+str(index+1)+" children")
	assert(path.get_child(index).get_child_count() > 0, "PathFollow at index " + str(index) + " does not have children")
	
	var curr_ball : Ball
	var center_ball : Ball = path.get_child(index).get_child(0)
	var color : Ball.Colors = center_ball.color
	var min_index_of_same_color : int = index
	var max_index_of_same_color : int = index

	for i in range(index-1, -1, -1):
		curr_ball = path.get_child(i).get_child(0)
		if curr_ball.color == color:
			min_index_of_same_color = i
		else:
			break
	
	for i in range(index+1, path.get_child_count()):
		curr_ball = path.get_child(i).get_child(0)
		if curr_ball.color == color:
			max_index_of_same_color = i
		else:
			break
	return [min_index_of_same_color, max_index_of_same_color]

##Returns true if the array is deletable, i.e., at least 3 balls of same color
func is_deletable(indexes : Array[int]):
	return is_range_connected(indexes) and (indexes[1]-indexes[0]) >= 2
	
##Returns true if the array is deletable, i.e., at least 3 balls of same color
func is_combo(index : int):
	var indexes : Array[int] = indexes_of_same_color_cluster(index)
	return not is_range_connected(indexes) and (indexes[1]-indexes[0]) >= 2

##Returns true if the array is deletable, i.e., at least 3 balls of same color
func is_range_connected(indexes : Array[int]):
	for i in range(indexes[0],indexes[1]+1):
		if (path.get_child(i-1).progress - path.get_child(i).progress) > spacing_between_balls*1.02:
			return false
	return true
