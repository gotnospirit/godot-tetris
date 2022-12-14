extends Node2D
class_name Screen

const FadeDuration:float = 1.0
const FadeColor:Color = Color("#000000")

var model:Game = null
var is_mobile:bool = false


func _enter_tree():
	is_mobile = UtilsMobile.IsMobile()

	if not is_mobile:
		get_viewport().connect("size_changed", self, "_on_screen_resized")
		Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")


func _ready():
	_disable_process()
	$Fade.set_dimension(get_viewport_rect().size)


func _exit_tree():
	if not is_mobile:
		get_viewport().disconnect("size_changed", self, "_on_screen_resized")
		Input.disconnect("joy_connection_changed", self, "_on_joy_connection_changed")


func set_model(g:Game) -> void:
	model = g


func fade_out(duration:float = FadeDuration, color:Color = FadeColor):
	_disable_process()
	$Fade.fade_out(color, duration, funcref(self, "_on_fade_out_completed"))


func fade_in(duration:float = FadeDuration, color:Color = FadeColor):
	_disable_process()
	$Fade.fade_in(color, duration, funcref(self, "_on_fade_in_completed"))


func _disable_process() -> void:
	set_process(false)
	set_process_input(false)


func _enable_process() -> void:
	set_process(true)
	set_process_input(true)


func _on_fade_out_completed():
	_enable_process()


func _on_fade_in_completed():
	pass


func _on_screen_resized() -> Vector2:
	var size:Vector2 = get_viewport_rect().size
	$Fade.set_dimension(size)
	return size


func _on_joy_connection_changed(_device:int, _connected:bool):
	pass
