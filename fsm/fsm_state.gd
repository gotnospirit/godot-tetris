extends Node
class_name FSM_State

onready var fsm:Node = get_parent()
onready var parent:Node = fsm.get_parent()

export (PackedScene) var _scene
var _node = null


func on_state_enter() -> void:
	print("Entering state: ", self.name)
	_node = _scene.instance()
	_node.set_model(parent.model)
	parent.add_child(_node)


func on_state_exit() -> void:
	print("Exiting state: ", self.name)
	_node.queue_free()
	_node = null
