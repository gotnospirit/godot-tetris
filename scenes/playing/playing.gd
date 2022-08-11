extends Screen

const showup_duration:float = 1.0
const status_width:int = 150

const TileSize:int = 32
const BorderColor:Color = Color8(128, 128, 128, 140)


func _enter_tree():
	print("Playing._enter_tree")
#	model.pretty_print("grid")
	$Pause.connect("exit", self, "_on_pause_exit")

	# build the borders
	var idx:int = 0
	var w:int = model.get_size().x
	for cell in model.cells:
		if Game.Cells.BORDER == cell:
			var x:int = idx % w
			var y:int = idx / w
			var node = UtilsDraw.new_tetromino(x, y, TileSize, BorderColor)
			$Borders.add_child(node)
		idx += 1

	_layout(get_viewport_rect().size)

	# connect events
	model.connect("next_selected", self, "_on_next_tetromino_selected")


func _ready():
	fade_out(showup_duration)
	model.select_next()


func _exit_tree():
	model.disconnect("next_selected", self, "_on_next_tetromino_selected")


func _input(_event):
	if Input.is_action_just_released("pause"):
		$Pause.show()
		# will resume in _on_pause_exit
		get_tree().paused = true


func _layout(size:Vector2) -> void:
	var grid_size:Vector2 = model.get_size()

	# status panel
	var status_panel_size:Vector2 = $Status.layout(Vector2(status_width, 0))

	# grid
	var grid_width:int = grid_size.x * TileSize
	var game_width:int = grid_width + TileSize + status_panel_size.x / 2
	var viewport_width:int = size.x
	var border_x:int = viewport_width / 2 - game_width / 2
	$Borders.position.x = border_x

	var grid_height:int = grid_size.y * TileSize
	var viewport_height:int = size.y
	$Borders.position.y = viewport_height - grid_height

	# status panel position
	$Status.position.x = $Borders.position.x + grid_width + TileSize
	$Status.position.y = $Borders.position.y


func _on_screen_resized() -> Vector2:
	var size:Vector2 = ._on_screen_resized()
	_layout(size)
	return size


func _on_pause_exit() -> void:
	get_tree().paused = false
	$Pause.hide()


func _on_next_tetromino_selected(t:Tetromino) -> void:
	$Status.set_next(t)
