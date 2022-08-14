extends Node
class_name FiniteStateMachine

var _current_state:FSM_State = null


func _exit_tree():
	if _current_state:
		_current_state.on_state_exit()
		_current_state = null


func change_state(state:String) -> void:
	if _current_state:
		_current_state.on_state_exit()

	_current_state = get_node(state)

	if _current_state:
		_current_state.on_state_enter()
