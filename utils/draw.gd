class_name UtilsDraw


static func new_tetromino(x:int, y:int, tile_size:int, color:Color) -> ColorRect:
	var pos:Vector2 = Vector2(x * tile_size, y * tile_size)

	var parent:ColorRect = ColorRect.new()
	parent.color = Color8(50, 50, 50)
	parent.rect_position = pos
	parent.rect_min_size = Vector2(tile_size, tile_size)

	var node:ColorRect = ColorRect.new()
	node.color = color
	node.rect_position = Vector2(1, 1)
	node.rect_min_size = Vector2(tile_size - 2, tile_size - 2)
	parent.add_child(node)

	return parent
