extends Screen

const ShowupDuration:float = 1.0
const TileSizes:Array = [32, 24, 16, 8]
const BorderColor:Color = Color8(128, 128, 128, 140)

var _timer:SceneTreeTimer = null
var _tile_size:int


func _enter_tree():
	$Pause.connect("exit", self, "_on_pause_exit")

	_layout(get_viewport_rect().size)

	_create_grid_cells()

	_bind_model()


func _ready():
	$Status.set_model(model.score)
	fade_out(ShowupDuration)


func _exit_tree():
	_unbind_model()


func _input(_event):
	if Input.is_action_just_released("pause"):
		$Pause.show()
		# will resume in _on_pause_exit
		get_tree().paused = true

	if Input.is_action_pressed("soft_drop"):
		var succeed:bool = model.soft_drop()
		if not succeed and _timer and _timer.time_left > 0.0:
			# we force the signal to be emitted
			# so the gameplay loop will detect
			# the collision faster
			_timer.emit_signal("timeout")

	if Input.is_action_just_released("sonic_drop"):
		model.sonic_drop()

	if Input.is_action_pressed("move_left"):
		model.move_left()

	if Input.is_action_pressed("move_right"):
		model.move_right()

	if Input.is_action_just_released("rotate_clockwise"):
		model.rotate(true)

	if Input.is_action_just_released("rotate_counterclockwise"):
		model.rotate(false)


func _create_grid_cells() -> void:
	var idx:int = 0
	var w:int = model.get_size().x

	for cell in model.cells:
		if Game.Cells.EMPTY == cell:
			idx += 1
			continue

		var color:Color = BorderColor
		var parent:Node2D = $Grid/Borders

		if Game.Cells.BORDER != cell:
			color = Tetromino.Colors[cell]
			parent = $Grid/Statics

		var node:ColorRect = UtilsTetromino.DrawCell(idx % w, idx / w, _tile_size, color)

		parent.add_child(node)
		idx += 1


func _layout(size:Vector2) -> void:
	var grid_node:Node2D = $Grid
	var status_node:Node2D = $Status
	var mask_node:ColorRect = $Grid/Mask

	var grid_size:Vector2 = model.get_size()

	var viewport_width:int = size.x
	var viewport_height:int = size.y

	var grid_width:int = 0
	var grid_height:int = 0
	var game_width:int = 0
	var border_x:int = 0
	var border_y:int = 0

	# given the available viewport' size,
	# we need to find the correct tile size we can use
	for tile_size in TileSizes:
		_tile_size = tile_size

		grid_width = grid_size.x * _tile_size
		grid_height = grid_size.y * _tile_size

		game_width = grid_width + _tile_size + status_node.get_min_width(_tile_size)

		border_x = (viewport_width - game_width) / 2
		border_y = viewport_height - grid_height - _tile_size

		if border_x > 0 and border_y > 0:
			break

	grid_node.position.x = border_x
	grid_node.position.y = border_y

	# mask
	var mask_height:int = Tetromino.MaxWidth * _tile_size
	mask_node.rect_min_size = Vector2(grid_width, mask_height)
	mask_node.rect_position.y = -mask_height

	# status panel position
	status_node.position.x = grid_node.position.x + grid_width + _tile_size
	status_node.position.y = grid_node.position.y
	status_node.layout(_tile_size)


func _bind_model() -> void:
	if model:
		model.connect("next_selected", self, "_on_next_tetromino_selected")
		model.connect("spawned", self, "_on_tetromino_spawned")
		model.connect("moved", self, "_on_tetromino_moved")
		model.connect("locked", self, "_on_tetromino_locked")
		model.connect("rotated", self, "_on_tetromino_rotated")
		model.connect("lines_cleared", self, "_on_lines_cleared")
		model.connect("gravity_applied", self, "_on_gravity_applied")
		model.connect("ghost_updated", self, "_on_ghost_updated")


func _unbind_model() -> void:
	if model:
		model.disconnect("next_selected", self, "_on_next_tetromino_selected")
		model.disconnect("spawned", self, "_on_tetromino_spawned")
		model.disconnect("moved", self, "_on_tetromino_moved")
		model.disconnect("locked", self, "_on_tetromino_locked")
		model.disconnect("rotated", self, "_on_tetromino_rotated")
		model.disconnect("lines_cleared", self, "_on_lines_cleared")
		model.disconnect("gravity_applied", self, "_on_gravity_applied")
		model.disconnect("ghost_updated", self, "_on_ghost_updated")


func _on_tetromino_locked() -> void:
	# move tetromino's children to the "static grid"
	# TODO: make the tetromino blink?
	UtilsGrid.MoveInto($Grid/Current, $Grid/Statics)

	# clear the ghost
	var parent:Node2D = $Grid/Ghost

	for node in parent.get_children():
		node.queue_free()
		parent.remove_child(node)


func _on_lines_cleared(lines:Array) -> void:
	# TODO: animation?
	UtilsGrid.RemoveLines($Grid/Statics, lines, _tile_size)
	model.apply_gravity()


func _on_gravity_applied(moved:Dictionary) -> void:
	# TODO: animation?
	UtilsGrid.MoveLines($Grid/Statics, moved, _tile_size)


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
	var parent:Node2D

	# draw the current tetromino
	parent = $Grid/Current
	UtilsTetromino.Draw(t, parent, _tile_size)
	parent.position = t.pos * _tile_size

	# draw its ghost
	parent = $Grid/Ghost
	UtilsTetromino.DrawGhost(t, parent, _tile_size)


func _on_tetromino_moved(t:Tetromino) -> void:
	$Grid/Current.position = t.pos * _tile_size


func _on_tetromino_rotated(t:Tetromino) -> void:
	UtilsTetromino.Rotate(t, $Grid/Current, _tile_size)
	UtilsTetromino.Rotate(t, $Grid/Ghost, _tile_size)


func _on_ghost_updated(pos:Vector2) -> void:
	$Grid/Ghost.position = pos * _tile_size


func _on_fade_out_completed():
	._on_fade_out_completed()
	_gameplay_loop()


func _gameplay_loop() -> void:
	model.spawn()

	while true:
		while true:
			_timer = get_tree().create_timer(model.get_falldown_delay(), false)
			yield(_timer, "timeout")

			var succeed:bool = model.falldown()
			if not succeed:
				break

		model.lock()

		model.check_for_completed_lines()

		var succeed:bool = model.spawn()
		if not succeed:
			# the game is over when the tetromino
			# we want to spawn collides directly
			break

	# TODO: play sound or animation before?
	model.set_status(Game.Status.GAME_OVER)
