extends Screen


func _enter_tree():
	$CenterContainer.rect_min_size = get_viewport_rect().size


func _ready():
	fade_out()


func _process(_delta):
	if Input.is_action_just_released("start_game"):
		fade_in()


func _on_fade_in_completed():
	._on_fade_in_completed()
	model.set_status(Game.Status.PLAYING)


func _on_screen_resized() -> Vector2:
	var size:Vector2 = ._on_screen_resized()
	$CenterContainer.rect_min_size = size
	return size
