extends Node2D

const FramePadding:int = 10

var _model:Scoring = null
var _tile_size:int = 32


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
	parent.position.y = (Tetromino.MaxWidth - o.height) * _tile_size / 2 + FramePadding


func get_min_width(tile_size:int) -> int:
	return Tetromino.MaxWidth * tile_size + FramePadding * 2


func layout(tile_size:int) -> void:
	_tile_size = tile_size

	# next tetromino preview
	var preview_width:int = Tetromino.MaxWidth * _tile_size
	var preview_height:int = Tetromino.MaxWidth * _tile_size

	$Frame/Preview.position.x = FramePadding
	$Frame/Preview.position.y = FramePadding

	# frame size
	var frame_width:int = preview_width + FramePadding * 2
	var frame_height:int = preview_height + FramePadding * 2

	$Frame.rect_size = Vector2(frame_width, frame_height)

	$Score.rect_size.x = frame_width
	$Level.rect_size.x = frame_width
	$Lines.rect_size.x = frame_width

	$Score.rect_position.y = FramePadding * 3 + preview_height
	$Level.rect_position.y = $Score.rect_position.y + FramePadding + $Score.rect_size.y
	$Lines.rect_position.y = $Level.rect_position.y + FramePadding + $Level.rect_size.y


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
