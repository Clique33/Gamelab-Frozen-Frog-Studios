class_name StateMachine extends Node

@export var alphabet : Array[String]#string encondings of actions accepted by the machine
@export var initial_state : State
var current_state : State

func _ready() -> void:
	for state in get_children():
		assert( is_instance_of(state, State), "StateMachine can only have State instances as children: ("+name+")")
	current_state = initial_state

#changes current_state given the action passed as string
func transition(action : String)-> void:
	assert( action in alphabet, "The given action ("+action+") is not defined for the current StateMachine ("+name+")")
	var temp : State = current_state.get_next_state(action)
	assert( temp != null, "The given action ("+action+") is not defined for the current State ("+current_state.name+") of the StateMachine ("+name+")")
	if current_state != temp:
		current_state.emit_signal("state_exited")
		current_state = temp
		current_state.emit_signal("state_entered")
