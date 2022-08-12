extends Screen

const TransitionDelay:float = 2.0


func _enter_tree():
	$CenterContainer.rect_min_size = get_viewport_rect().size


func _ready():
	fade_out()


func _on_fade_out_completed():
	._on_fade_out_completed()
	get_tree().create_timer(TransitionDelay).connect("timeout", self, "_on_timer_timeout")


func _on_fade_in_completed():
	._on_fade_in_completed()
	model.set_status(Game.Status.INIT)


func _on_timer_timeout():
	fade_in()


func _on_screen_resized() -> Vector2:
	var size:Vector2 = ._on_screen_resized()
	$CenterContainer.rect_min_size = size
	return size
