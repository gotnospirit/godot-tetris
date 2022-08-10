extends Node2D

const TileSize:int = 32

const FrameMargin:int = 10
const BorderWidth:int = 2
const BorderRadius:int = 10


func layout(min_size:Vector2) -> Vector2:
	var score_label:Vector2 = $Score.rect_size
	var score_count:Vector2 = $NbScore.rect_size

	# next tetromino
	var preview_width:int = Tetromino.Width * TileSize
	var preview_height:int = Tetromino.Width * TileSize

	# frame size
	var frame_width:int = score_label.x + score_count.x + FrameMargin * 3
	var frame_height:int = preview_height + max(score_label.y, score_count.y) + FrameMargin * 3
	$Frame.rect_size = Vector2(
		max(max(frame_width, preview_width), min_size.x),
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

	# children position
	$Previous.position.x = FrameMargin
	$Previous.position.y = FrameMargin
	$Score.rect_position.x = FrameMargin
	$Score.rect_position.y = FrameMargin * 2 + preview_height
	# we align the score count to the right
	$NbScore.rect_position.x = $Frame.rect_size.x - FrameMargin - score_count.x
	$NbScore.rect_position.y = FrameMargin * 2 + preview_height

	return $Frame.rect_size
