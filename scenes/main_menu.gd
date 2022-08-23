extends Screen

const MenuText:String = "Press [%s] to start a new game"
const TouchScreenText:String = "Tap to start a new game"


func _enter_tree():
	$CenterContainer.rect_min_size = get_viewport_rect().size


func _ready():
	if is_mobile:
		_update_label_for_mobile()
	else:
		_update_label()
	fade_out()


func _input(event):
	if event.is_action_released("start_game") or event is InputEventScreenTouch:
		fade_in()


func _on_fade_in_completed():
	._on_fade_in_completed()
	model.set_status(Game.Status.PLAYING)


func _on_screen_resized() -> Vector2:
	var size:Vector2 = ._on_screen_resized()
	$CenterContainer.rect_min_size = size
	return size


func _update_label() -> void:
	var key_names:PoolStringArray = UtilsInput.GetKeyNames("start_game")
	var key_str:String = "n/a" if key_names.empty() else key_names.join(" / ")
	$CenterContainer/Label.text = MenuText % key_str


func _update_label_for_mobile() -> void:
	$CenterContainer/Label.text = TouchScreenText


func _on_joy_connection_changed(device:int, connected:bool):
	._on_joy_connection_changed(device, connected)
	_update_label()
