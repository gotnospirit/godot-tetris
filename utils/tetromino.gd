class_name UtilsTetromino

const CellBorderColor:Color = Color8(50, 50, 50)
const GhostColor:Color = Color8(127, 127, 127)


static func Rotate(t:Tetromino, parent:Node2D, tile_size:int) -> void:
	# Reset the children position
	var node_idx:int = 0

	for idx in range(t.get_length()):
		if t.is_empty(idx):
			continue

		var x:int = idx % t.width
		var y:int = idx / t.width

		var node:ColorRect = parent.get_child(node_idx)
		var pos:Vector2 = Vector2(x * tile_size, y * tile_size)
		node.rect_position = pos

		node_idx += 1


static func DrawGhost(t:Tetromino, parent:Node2D, tile_size:int) -> void:
	_Draw(t, parent, tile_size, GhostColor)

	for node in parent.get_children():
		var n:ColorRect = ColorRect.new()
		n.color = CellBorderColor
		n.rect_position = Vector2(2, 2)
		n.rect_min_size = Vector2(tile_size - 4, tile_size - 4)
		node.add_child(n)


static func Draw(t:Tetromino, parent:Node2D, tile_size:int) -> void:
	_Draw(t, parent, tile_size, t.color)


static func DrawCell(x:int, y:int, tile_size:int, color:Color) -> ColorRect:
	var pos:Vector2 = Vector2(x * tile_size, y * tile_size)

	var parent:ColorRect = ColorRect.new()
	parent.color = CellBorderColor
	parent.rect_position = pos
	parent.rect_min_size = Vector2(tile_size, tile_size)

	var node:ColorRect = ColorRect.new()
	node.color = color
	node.rect_position = Vector2(1, 1)
	node.rect_min_size = Vector2(tile_size - 2, tile_size - 2)
	parent.add_child(node)

	return parent


static func _Draw(t:Tetromino, parent:Node2D, tile_size:int, color:Color) -> void:
	for idx in range(t.get_length()):
		if t.is_empty(idx):
			continue

		var x:int = idx % t.width
		var y:int = idx / t.width
		var node:ColorRect = DrawCell(x, y, tile_size, color)
		parent.add_child(node)
