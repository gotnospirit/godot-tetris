extends Screen

const ShowupDuration:float = 1.0
const StatusWidth:int = 150
const TileSize:int = 32
const BorderColor:Color = Color8(128, 128, 128, 140)

var falldown_delay:float = 1.0
var _timer:SceneTreeTimer = null


func _enter_tree():
	$Pause.connect("exit", self, "_on_pause_exit")

	_create_grid_cells()

	_layout(get_viewport_rect().size)
	$Status.layout(Vector2(StatusWidth, 0))

	_bind_model()


func _ready():
	fade_out(ShowupDuration)


func _exit_tree():
	_unbind_model()


func _input(_event):
	if Input.is_action_just_released("pause"):
		$Pause.show()
		# will resume in _on_pause_exit
		get_tree().paused = true

	if Input.is_action_just_released("falldown"):
		var collided:bool = model.falldown()
		if collided and _timer and _timer.time_left > 0.0:
			# we force the signal to be emitted
			# so the gameplay loop will detect
			# the collision faster
			_timer.emit_signal("timeout")

	if Input.is_action_just_released("move_left"):
		model.move_left()

	if Input.is_action_just_released("move_right"):
		model.move_right()

	if Input.is_action_just_released("rotate"):
		model.rotate()


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

		var node:ColorRect = UtilsTetromino.DrawCell(idx % w, idx / w, TileSize, color)

		parent.add_child(node)
		idx += 1


func _layout(size:Vector2) -> void:
	var grid_node:Node2D = $Grid
	var status_node:Node2D = $Status

	var grid_size:Vector2 = model.get_size()

	# grid
	var grid_width:int = grid_size.x * TileSize
	var game_width:int = grid_width + TileSize + status_node.get_size().x / 2
	var viewport_width:int = size.x
	var border_x:int = (viewport_width - game_width) / 2
	grid_node.position.x = border_x

	var grid_height:int = grid_size.y * TileSize
	var viewport_height:int = size.y
	grid_node.position.y = viewport_height - grid_height

	# status panel position
	status_node.position.x = grid_node.position.x + grid_width + TileSize
	status_node.position.y = grid_node.position.y


func _bind_model() -> void:
	if model:
		model.connect("next_selected", self, "_on_next_tetromino_selected")
		model.connect("spawned", self, "_on_tetromino_spawned")
		model.connect("moved", self, "_on_tetromino_moved")
		model.connect("cells_updated", self, "_on_grid_updated")
		model.connect("rotated", self, "_on_tetromino_rotated")


func _unbind_model() -> void:
	if model:
		model.disconnect("next_selected", self, "_on_next_tetromino_selected")
		model.disconnect("spawned", self, "_on_tetromino_spawned")
		model.disconnect("moved", self, "_on_tetromino_moved")
		model.disconnect("cells_updated", self, "_on_grid_updated")
		model.disconnect("rotated", self, "_on_tetromino_rotated")


func _on_grid_updated() -> void:
	var from:Node2D = $Grid/Current
	var to:Node2D = $Grid/Statics

	# move tetromino's children to the "static grid"
	for node in from.get_children():
		var dup:ColorRect = node.duplicate()
		# don't forget to offset them
		dup.rect_position += from.position
		to.add_child(dup)


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

	if old_y < 0 and t.pos.y != old_y:
		UtilsTetromino.UpdateMove(t, parent)

	parent.position = t.pos * Vector2(TileSize, TileSize)


func _on_tetromino_rotated(t:Tetromino) -> void:
	UtilsTetromino.UpdateRotate(t, $Grid/Current, TileSize)


func _on_fade_out_completed():
	._on_fade_out_completed()
	_gameplay_loop()


func _gameplay_loop() -> void:
	model.select_next()
	model.spawn()

	while true:
		while true:
			_timer = get_tree().create_timer(falldown_delay / model.speed, false)
			yield(_timer, "timeout")

			var collided:bool = model.falldown()
			if collided:
				break

		model.consolidate()

		# TODO: make the tetromino blink?

		# TODO: search for completed lines

		var succeed:bool = model.spawn()
		if not succeed:
			# the game is over when the tetromino
			# we want to spawn collides directly
			break

	# TODO: play sound or animation before?
	model.set_status(Game.Status.GAME_OVER)
