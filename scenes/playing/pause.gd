extends Screen

const toggle_duration:float = .5
const toggle_color:Color = Color("#A0000000")

signal exit


func _enter_tree():
	var size:Vector2 = get_viewport_rect().size
	$CenterContainer.rect_min_size = size


func show():
	.show()
	fade_in(toggle_duration, toggle_color)


func _input(_event):
	if Input.is_action_just_released("pause"):
		$CenterContainer.hide()
		fade_out(toggle_duration, toggle_color)


func _on_fade_in_completed():
	._on_fade_in_completed()
	._enable_process()
	$CenterContainer.show()


func _on_fade_out_completed():
	._on_fade_out_completed()
	._disable_process()
	emit_signal("exit")


func _on_screen_resized() -> Vector2:
	var size:Vector2 = ._on_screen_resized()
	$CenterContainer.rect_min_size = size
	return size
