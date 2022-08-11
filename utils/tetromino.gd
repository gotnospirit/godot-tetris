class_name UtilsTetromino


static func Draw(t:Tetromino, parent:Node2D, tile_size:int) -> void:
	for idx in range(t.get_length()):
		if t.is_empty(idx):
			continue

		var x:int = idx % t.width
		var y:int = idx / t.width
		var node = DrawCell(x, y, tile_size, t.color, y + t.cell_y < 0)
		parent.add_child(node)


static func DrawCell(x:int, y:int, tile_size:int, color:Color, transparent:bool = false) -> ColorRect:
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

	if transparent:
		parent.modulate.a = 0

	return parent
