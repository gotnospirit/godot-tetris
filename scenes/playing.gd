extends Screen

const showup_duration:float = 1.0

const TileSize:int = 32


func _enter_tree():
	print("Playing._enter_tree")
	model.pretty_print("grid")

	# build the borders
	var idx:int = 0
	var w:int = model.get_size().x
	for cell in model.cells:
		if Game.Cells.BORDER == cell:
			var x:int = idx % w
			var y:int = idx / w
			var node = _create_block(x, y, TileSize, Color(255, 0, 0, 1))
			$Borders.add_child(node)
		idx += 1

	_layout(get_viewport_rect().size)


func _ready():
	fade_out(showup_duration)


func _create_block(x:int, y:int, tile_size:int, color:Color) -> ColorRect:
	var pos:Vector2 = Vector2(x * tile_size, y * tile_size)
	var node:ColorRect = ColorRect.new()
	node.color = color
	node.rect_position = pos
	node.rect_min_size = Vector2(tile_size, tile_size)
	return node


func _layout(size:Vector2) -> void:
	var grid_size:Vector2 = model.get_size()

	# center it horizontaly
	var grid_width:int = grid_size.x * TileSize
	var viewport_width:int = size.x
	var border_x:int = viewport_width / 2 - grid_width / 2
	$Borders.position.x = border_x

	# align it on the bottom of the screen
	var grid_height:int = grid_size.y * TileSize
	var viewport_height:int = size.y
	$Borders.position.y = viewport_height - grid_height


func _on_screen_resized() -> Vector2:
	var size:Vector2 = ._on_screen_resized()
	_layout(size)
	return size
