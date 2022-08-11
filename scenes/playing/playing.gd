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
			var node = UtilsTetromino.DrawCell(x, y, TileSize, BorderColor)
			$Grid/Borders.add_child(node)
		idx += 1

	_layout(get_viewport_rect().size)

	# connect events
	model.connect("next_selected", self, "_on_next_tetromino_selected")
	model.connect("spawned", self, "_on_tetromino_spawned")
	model.connect("moved", self, "_on_tetromino_moved")


func _ready():
	fade_out(showup_duration)


func _exit_tree():
	model.disconnect("next_selected", self, "_on_next_tetromino_selected")
	model.disconnect("spawned", self, "_on_tetromino_spawned")
	model.disconnect("moved", self, "_on_tetromino_moved")


func _input(_event):
	if Input.is_action_just_released("pause"):
		$Pause.show()
		# will resume in _on_pause_exit
		get_tree().paused = true

	if Input.is_action_just_released("falldown"):
		model.falldown()


func _layout(size:Vector2) -> void:
	var grid_node:Node2D = $Grid
	var status_node:Node2D = $Status

	var grid_size:Vector2 = model.get_size()

	# status panel
	var status_panel_size:Vector2 = status_node.layout(Vector2(status_width, 0))

	# grid
	var grid_width:int = grid_size.x * TileSize
	var game_width:int = grid_width + TileSize + status_panel_size.x / 2
	var viewport_width:int = size.x
	var border_x:int = viewport_width / 2 - game_width / 2
	grid_node.position.x = border_x

	var grid_height:int = grid_size.y * TileSize
	var viewport_height:int = size.y
	grid_node.position.y = viewport_height - grid_height

	# status panel position
	status_node.position.x = grid_node.position.x + grid_width + TileSize
	status_node.position.y = grid_node.position.y


func _on_screen_resized() -> Vector2:
	var size:Vector2 = ._on_screen_resized()
	_layout(size)
	return size


func _on_pause_exit() -> void:
	get_tree().paused = false
	$Pause.hide()


func _on_next_tetromino_selected(t:Tetromino) -> void:
	$Status.set_next(t)


func _on_tetromino_spawned(t:Tetromino) -> void:
	var parent:Node2D = $Grid/Current
	for node in parent.get_children():
		node.queue_free()
		parent.remove_child(node)

	UtilsTetromino.Draw(t, parent, TileSize)
	parent.position = t.pos * Vector2(TileSize, TileSize)


func _on_tetromino_moved(t:Tetromino, old_y:int) -> void:
	var parent:Node2D = $Grid/Current
	UtilsTetromino.Move(t, parent, old_y)
	parent.position = t.pos * Vector2(TileSize, TileSize)


func _on_fade_out_completed():
	._on_fade_out_completed()
	_gameplay_loop()


func _gameplay_loop() -> void:
	model.select_next()
	model.spawn()
