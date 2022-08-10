extends Node2D
class_name Screen

var model:Game = null

const fade_duration:float = 1.0
const fade_color:Color = Color("#000000")


func _enter_tree():
	get_viewport().connect("size_changed", self, "_on_screen_resized")


func _ready():
#	print("Screen._ready: ", self)
	_disable_process()

	$Fade.set_dimension(get_viewport_rect().size)


func _exit_tree():
	get_viewport().disconnect("size_changed", self, "_on_screen_resized")


func set_model(g:Game) -> void:
	model = g


func fade_out(duration:float = fade_duration, color:Color = fade_color):
	$Fade.fade_out(color, duration, funcref(self, "_on_fade_out_completed"))


func fade_in(duration:float = fade_duration, color:Color = fade_color):
	_disable_process()

	$Fade.fade_in(color, duration, funcref(self, "_on_fade_in_completed"))


func _disable_process() -> void:
	set_process(false)
	set_process_input(false)


func _enable_process() -> void:
	set_process(true)
	set_process_input(true)


func _on_fade_out_completed():
#	print("Screen._on_fade_out_completed: ", self)
	_enable_process()


func _on_fade_in_completed():
#	print("Screen._on_fade_in_completed: ", self)
	pass


func _on_screen_resized() -> Vector2:
	var size:Vector2 = get_viewport_rect().size
	$Fade.set_dimension(size)
	return size
