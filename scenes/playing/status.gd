extends Node2D

const TileSize:int = 32
const FramePadding:int = 10
const BorderWidth:int = 2
const BorderRadius:int = 10

var model:Scoring = null


func _exit_tree():
	_unbind_model()


func set_model(s:Scoring) -> void:
	model = s

	_on_updated(s.score, s.lines, s.level)
	_bind_model()


func set_next(t:Tetromino) -> void:
	for node in $Preview.get_children():
		node.queue_free()
		$Preview.remove_child(node)

	var o:Tetromino = t.get_preview()
	UtilsTetromino.Draw(o, $Preview, TileSize)

	# center it
	$Preview.position.x = (Tetromino.MaxWidth - o.width) * TileSize / 2 + FramePadding
	$Preview.position.y = (Tetromino.MaxWidth - o.height) * TileSize / 2 + FramePadding


func get_size() -> Vector2:
	return $Frame.rect_size


func layout(min_size:Vector2) -> void:
	# next tetromino preview
	var preview_width:int = Tetromino.MaxWidth * TileSize
	var preview_height:int = Tetromino.MaxWidth * TileSize

	var score_label:Vector2 = $Score/Label.rect_size
	var score_count:Vector2 = $Score/Count.rect_size
	var score_width:int = score_label.x + FramePadding + score_count.x
	var score_height:int = max(score_label.y, score_count.y)

	var level_label:Vector2 = $Level/Label.rect_size
	var level_count:Vector2 = $Level/Count.rect_size
	var level_width:int = level_label.x + FramePadding + level_count.x
	var level_height:int = max(level_label.y, level_count.y)

	var lines_label:Vector2 = $Lines/Label.rect_size
	var lines_count:Vector2 = $Lines/Count.rect_size
	var lines_width:int = lines_label.x + FramePadding + lines_count.x
	var lines_height:int = max(lines_label.y, lines_count.y)

	# frame size
	var frame_width:int = max(preview_width, max(score_width, max(level_width, lines_width))) + FramePadding * 2
	var frame_height:int = preview_height + score_height + level_height + lines_height + FramePadding * 5
	$Frame.rect_size = Vector2(
		max(frame_width, min_size.x),
		max(frame_height, min_size.y)
	)

	var style = $Frame.get_stylebox("panel", "")

	# frame border width
	style.border_width_top = BorderWidth
	style.border_width_bottom = BorderWidth
	style.border_width_left = BorderWidth
	style.border_width_right = BorderWidth

	# frame border radius
	style.corner_radius_top_left = BorderRadius
	style.corner_radius_top_right = BorderRadius
	style.corner_radius_bottom_left = BorderRadius
	style.corner_radius_bottom_right = BorderRadius

	# align rows
	$Score.position.y = FramePadding * 2 + preview_height
	$Level.position.y = $Score.position.y + FramePadding + score_height
	$Lines.position.y = $Level.position.y + FramePadding + level_height

	# align the texts
	$Score/Label.rect_position.x = FramePadding
	$Score/Count.rect_position.x = $Frame.rect_size.x - FramePadding - score_count.x

	$Level/Label.rect_position.x = FramePadding
	$Level/Count.rect_position.x = $Frame.rect_size.x - FramePadding - level_count.x

	$Lines/Label.rect_position.x = FramePadding
	$Lines/Count.rect_position.x = $Frame.rect_size.x - FramePadding - lines_count.x


func _bind_model() -> void:
	if model:
		model.connect("updated", self, "_on_updated")


func _unbind_model() -> void:
	if model:
		model.disconnect("updated", self, "_on_updated")


func _on_updated(score:int, lines:int, level:int) -> void:
	$Score/Count.text = str(score)
	$Level/Count.text = str(level)
	$Lines/Count.text = str(lines)
