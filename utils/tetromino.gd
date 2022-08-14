class_name UtilsTetromino

const CellBorderColor:Color = Color8(50, 50, 50)
const GhostColor:Color = Color8(127, 127, 127)


static func Rotate(t:Tetromino, parent:Node2D, tile_size:int) -> void:
	_Rotate(t, parent, tile_size, false)


static func RotateGhost(t:Tetromino, parent:Node2D, tile_size:int) -> void:
	_Rotate(t, parent, tile_size, true)


static func _Rotate(t:Tetromino, parent:Node2D, tile_size:int, is_ghost:bool) -> void:
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

		if not is_ghost:
			var cell_y:int = y + t.pos.y
			node.modulate.a = 0 if cell_y < 0 else 1

		node_idx += 1


static func UpdateTransparency(t:Tetromino, parent:Node2D) -> void:
	var node_idx:int = 0

	for idx in range(t.get_length()):
		if t.is_empty(idx):
			continue

		var cell_y:int = (idx / t.height) + t.pos.y
		# not visible yet
		if cell_y < 0:
			node_idx += 1
			continue

		# remove transparency
		var node:ColorRect = parent.get_child(node_idx)
		if 0 == node.modulate.a:
			node.modulate.a = 1
		node_idx += 1


static func DrawGhost(t:Tetromino, parent:Node2D, tile_size:int) -> void:
	_Draw(t, parent, tile_size, true)

	for node in parent.get_children():
		var n:ColorRect = ColorRect.new()
		n.color = CellBorderColor
		n.rect_position = Vector2(2, 2)
		n.rect_min_size = Vector2(tile_size - 4, tile_size - 4)
		node.add_child(n)


static func Draw(t:Tetromino, parent:Node2D, tile_size:int) -> void:
	_Draw(t, parent, tile_size, false)


static func DrawCell(x:int, y:int, tile_size:int, color:Color, transparent:bool = false) -> ColorRect:
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

	if transparent:
		parent.modulate.a = 0

	return parent


static func _Draw(t:Tetromino, parent:Node2D, tile_size:int, is_ghost:bool) -> void:
	for idx in range(t.get_length()):
		if t.is_empty(idx):
			continue

		var x:int = idx % t.width
		var y:int = idx / t.width
		var color:Color = t.color if not is_ghost else GhostColor
		var transparent:bool = y + t.pos.y < 0 if not is_ghost else false
		var node:ColorRect = DrawCell(x, y, tile_size, color, transparent)
		parent.add_child(node)
