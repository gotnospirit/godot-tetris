class_name UtilsTetromino


static func UpdateRotate(t:Tetromino, parent:Node2D, tile_size:int) -> void:
	# Reset the children position and transparency
	var node_idx:int = 0
	for idx in range(t.get_length()):
		if t.is_empty(idx):
			continue

		var x:int = idx % t.width
		var y:int = idx / t.width

		var node:ColorRect = parent.get_child(node_idx)
		var pos:Vector2 = Vector2(x * tile_size, y * tile_size)
		node.rect_position = pos

		var cell_y:int = y + t.pos.y
		node.modulate.a = 0 if cell_y < 0 else 1

		node_idx += 1


static func UpdateMove(t:Tetromino, parent:Node2D) -> void:
	var node_idx:int = 0
	for idx in range(t.get_length()):
		if t.is_empty(idx):
			continue

		var cell_y:int = (idx / t.width) + t.pos.y
		# not visible yet
		if cell_y < 0:
			node_idx += 1
			continue
		# already visible
		elif cell_y > 0:
			break

		# remove transparency
		parent.get_child(node_idx).modulate.a = 1
		node_idx += 1


static func Draw(t:Tetromino, parent:Node2D, tile_size:int) -> void:
	for idx in range(t.get_length()):
		if t.is_empty(idx):
			continue

		var x:int = idx % t.width
		var y:int = idx / t.width
		var node:ColorRect = DrawCell(x, y, tile_size, t.color, y + t.pos.y < 0)
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
