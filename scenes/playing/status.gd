extends Node2D

var _model:Scoring = null
var _tile_size:int = -1
var _size:Vector2 = Vector2.ZERO


func _exit_tree():
	_unbind_model()


func set_model(s:Scoring) -> void:
	_model = s

	_on_updated(s.score, s.lines, s.level)
	_bind_model()


func set_next(t:Tetromino) -> void:
	var parent:Node2D = $Frame/Preview

	for node in parent.get_children():
		node.queue_free()
		parent.remove_child(node)

	var o:Tetromino = t.get_preview()
	UtilsTetromino.Draw(o, parent, _tile_size)

	# center it
	parent.position.x = ($Frame.rect_size.x - o.width * _tile_size) / 2
	parent.position.y = ($Frame.rect_size.y - o.height * _tile_size) / 2


func get_size(tile_size:int, layout_horizontal:bool) -> Vector2:
	if _tile_size == tile_size:
		return _size

	var preview_width:int = Tetromino.MaxWidth * tile_size
	var frame_padding:int = UtilsMobile.GetFramePadding()

	var score_width:int = $Score.get_width()
	var level_width:int = $Level.get_width()
	var lines_width:int = $Lines.get_width()

	var status_line_height:int = $Score.get_height()

	if layout_horizontal:
		_size.x = preview_width + frame_padding * 3 + int(max(score_width, max(level_width, lines_width)))
		_size.y = preview_width + frame_padding * 2
	else:
		_size.x = int(max(preview_width, max(score_width, max(level_width, lines_width)))) + frame_padding * 2
		_size.y = preview_width + frame_padding * 2 + 3 * (status_line_height + frame_padding)

	_tile_size = tile_size

	return _size


func layout(width:int, layout_horizontal:bool) -> void:
	var size:Vector2 = get_size(_tile_size, layout_horizontal)
	var frame_padding:int = UtilsMobile.GetFramePadding()

	# next tetromino preview
	var preview_size:int = Tetromino.MaxWidth * _tile_size

	$Frame/Preview.position.x = frame_padding
	$Frame/Preview.position.y = frame_padding

	# frame size
	var frame_size:int = preview_size + frame_padding * 2

	$Frame.rect_size = Vector2(frame_size, frame_size)
	UtilsMobile.UpdatePanel($Frame)

	if layout_horizontal:
		var max_width:int = int(max($Score.get_width(), max($Level.get_width(), $Lines.get_width())))

		$Score.rect_position.x = width - max_width
		$Level.rect_position.x = width - max_width
		$Lines.rect_position.x = width - max_width

		$Score.rect_size.x = max_width
		$Level.rect_size.x = max_width
		$Lines.rect_size.x = max_width
	else:
		$Score.rect_size.x = size.x
		$Level.rect_size.x = size.x
		$Lines.rect_size.x = size.x

		$Score.rect_position.y = frame_size

	$Score.rect_size.y = $Score.get_height()
	$Level.rect_size.y = $Level.get_height()
	$Lines.rect_size.y = $Lines.get_height()

	$Score.rect_position.y += frame_padding
	$Level.rect_position.y = $Score.rect_position.y + frame_padding + $Score.rect_size.y
	$Lines.rect_position.y = $Level.rect_position.y + frame_padding + $Level.rect_size.y


func _bind_model() -> void:
	if _model:
		_model.connect("updated", self, "_on_updated")


func _unbind_model() -> void:
	if _model:
		_model.disconnect("updated", self, "_on_updated")


func _on_updated(score:int, lines:int, level:int) -> void:
	$Score.count = score
	$Level.count = level
	$Lines.count = lines
