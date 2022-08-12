extends Screen

const MenuText:String = "Press [%s] to start a new game"


func _enter_tree():
	$CenterContainer.rect_min_size = get_viewport_rect().size


func _ready():
	_update_label()
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


func _update_label() -> void:
	var key_names:PoolStringArray = UtilsInput.GetKeyNames("start_game")
	var key_str:String = "n/a" if key_names.empty() else key_names.join(" / ")
	$CenterContainer/Label.text = MenuText % key_str


func _on_joy_connection_changed(device:int, connected:bool):
	._on_joy_connection_changed(device, connected)
	_update_label()
