extends Node2D

const TileSize:int = 32

const FramePadding:int = 10
const BorderWidth:int = 2
const BorderRadius:int = 10


func set_next(t:Tetromino) -> void:
	for node in $Preview.get_children():
		node.queue_free()
		$Preview.remove_child(node)

	UtilsTetromino.Draw(t, $Preview, TileSize)


func layout(min_size:Vector2) -> Vector2:
	# next tetromino preview
	var preview_width:int = Tetromino.Width * TileSize
	var preview_height:int = Tetromino.Width * TileSize

	var score_label:Vector2 = $Score/Label.rect_size
	var score_count:Vector2 = $Score/Count.rect_size
	var score_width:int = score_label.x + FramePadding + score_count.x
	var score_height:int = max(score_label.y, score_count.y)

	var level_label:Vector2 = $Level/Label.rect_size
	var level_count:Vector2 = $Level/Count.rect_size
	var level_width:int = level_label.x + FramePadding + level_count.x
	var level_height:int = max(level_label.y, level_count.y)

	# frame size
	var frame_width:int = max(preview_width, max(score_width, level_width)) + FramePadding * 2
	var frame_height:int = preview_height + score_height + level_height + FramePadding * 4
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
	$Preview.position.x = FramePadding
	$Preview.position.y = FramePadding
	$Score.position.y = $Preview.position.y + FramePadding + preview_height
	$Level.position.y = $Score.position.y + FramePadding + score_height

	# align the texts
	$Score/Label.rect_position.x = FramePadding
	$Score/Count.rect_position.x = $Frame.rect_size.x - FramePadding - score_count.x
	$Level/Label.rect_position.x = FramePadding
	$Level/Count.rect_position.x = $Frame.rect_size.x - FramePadding - level_count.x

	return $Frame.rect_size
