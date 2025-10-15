class_name State extends Node

signal state_entered
signal state_exited

#var name is relevant, coming from Node
@export var transitions : Dictionary[String,State]

func _ready() -> void:
	assert(is_instance_of(get_parent(),StateMachine),"A State instance has to be the child os a StateMachine: ("+name+")")

func get_next_state(action: String) -> State:
	return transitions.get(action)
