class_name Game

enum Status { INIT, PLAYING, GAME_OVER }

const Width:int = 12
const Height:int = 18
const Cells = {
	BORDER = 9,
	EMPTY = 0
}

var status:int
var cells:Array = []
var next:Tetromino = null
var current:Tetromino = null
var speed:float = 1.0
var ghost_pos:Vector2 = Vector2.ZERO

signal status_updated
signal next_selected
signal spawned
signal moved
signal locked
signal rotated
signal lines_cleared
signal gravity_applied
signal ghost_updated


func _init():
	status = Status.INIT

	cells.resize(Width * Height)
	for i in range(Width * Height):
		var is_border:bool = (i % Width == 0) or (i % Width == Width - 1) or (int(i / Width) == Height - 1)
		cells[i] = Cells.BORDER if is_border else Cells.EMPTY


func select_next() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var type:int = rng.randi_range(0, Tetromino.Types.size() - 1)

	next = Tetromino.new(type)
	emit_signal("next_selected", next)


func spawn() -> bool:
	if not next:
		push_error("Next tetromino not selected yet")
		return false

	current = next
	select_next()

	current.pos = Vector2((Width - current.width) / 2, -2)

	if detect_collision(current, Vector2.DOWN):
		current = null
		return false

	emit_signal("spawned", current)
	_update_ghost_pos()
	return true


func move_left() -> void:
	var succeed:bool = _move(Vector2.LEFT)

	if succeed:
		_update_ghost_pos()


func move_right() -> void:
	var succeed:bool = _move(Vector2.RIGHT)

	if succeed:
		_update_ghost_pos()


func sonic_drop() -> void:
	if not current:
		return

	# sonic drop is a non-locking hard drop
	# we just move the current tetromino to ghost position
	current.pos = ghost_pos
	emit_signal("moved", current)


func falldown() -> bool:
	return _move(Vector2.DOWN)


func rotate(clockwise:bool) -> void:
	if not current:
		return

	# no need to rotate a square
	if current.type == Tetromino.Types.TetriminoO:
		return

	var new_rotation:int = current.rotation
	new_rotation += 1 if clockwise else -1

	if new_rotation < 0:
		new_rotation = Tetromino.Rotation.size() - 1
	elif new_rotation >= Tetromino.Rotation.size():
		new_rotation = 0

	var old_rotation:int = current.rotation
	current.rotate(new_rotation)

	if detect_collision(current, Vector2.ZERO):
		# collision occured -> revert rotation
		current.rotate(old_rotation)
		return

	emit_signal("rotated", current)
	_update_ghost_pos()


func lock() -> void:
	if not current:
		return

	# "move" current tetromino into the grid
	for idx in range(current.get_length()):
		if current.is_empty(idx):
			continue

		var px:int = idx % current.width
		var py:int = idx / current.width
		var fi:int = (current.pos.y + py) * Width + (current.pos.x + px)

		if fi < 0:
			continue

		if cells[fi] != Cells.EMPTY:
			push_error(
				"something is wrong here: [px:" + str(px) + ", py:" + str(py)
				+ ", fi:" + str(fi) + ", content:" + str(cells[fi]) + "]"
			)
			break

		cells[fi] = current.type + 1

	current = null

	emit_signal("locked")


func check_for_completed_lines() -> void:
	var ret:Array = []

	# from bottom to top, detect completed lines
	# and clear their cells
	for y in range(Height - 2, -1, -1):
		var line_cells:Dictionary = _get_line(y)

		if _is_completed_line(line_cells):
			for cell_idx in line_cells:
				cells[cell_idx] = Cells.EMPTY

			ret.append(y)

	if not ret.empty():
		# TODO: compute and update score
		emit_signal("lines_cleared", ret)


func apply_gravity() -> void:
	# from bottom to top, accumulate empty lines
	# and when we encounter a non-empty one
	# move the content of its cells to
	# first empty line, then accumulate it in the empty lines
	var empty_lines:Array = []
	var moved_lines:Dictionary = {}

	for y in range(Height - 2, -1, -1):
		var line_cells:Dictionary = _get_line(y)

		if _is_empty_line(line_cells):
			empty_lines.push_back(y)
		elif not empty_lines.empty():
			var target_y:int = empty_lines.pop_front()
			var diff_y:int = target_y - y

			for cell_idx in line_cells:
				var target_idx:int = cell_idx + diff_y * Width

				cells[target_idx] = cells[cell_idx]
				cells[cell_idx] = Cells.EMPTY

			empty_lines.push_back(y)
			moved_lines[y] = target_y

	if not moved_lines.empty():
		emit_signal("gravity_applied", moved_lines)


func get_size() -> Vector2:
	return Vector2(Width, Height)


func set_status(new_status:int) -> void:
	if new_status != status:
		status = new_status
		emit_signal("status_updated", new_status)


func detect_collision(t:Tetromino, offset:Vector2) -> bool:
	var cell_x:int = t.pos.x + offset.x
	var cell_y:int = t.pos.y + offset.y

	for idx in range(t.get_length()):
		var px:int = idx % t.width

		# We skip empty cells
		if t.is_empty(idx):
			continue

		if cell_x + px <= 0 or cell_x + px >= Width - 1:
#			print("border collision")
			return true

		var py:int = idx / t.width

		if cell_y + py >= Height:
#			print("out of bounds")
			return true

		# We only consider visible cells
		if cell_y + py >= 0:
			var fi:int = (cell_y + py) * Width + (cell_x + px)

			if cells[fi] != Cells.EMPTY:
#				print("cell collision")
				return true

	return false


func _update_ghost_pos() -> void:
	if not current:
		return

	# from top to bottom, test collision with each line,
	# if not detected, update the ghost pos
	# if detected then stop the loop
	var updated:bool = false
	for y in range(current.pos.y + 1, Height):
		var diff_y:int = y - current.pos.y

		if detect_collision(current, Vector2(0, diff_y)):
			break

		ghost_pos = Vector2(current.pos.x, y)
		updated = true

	if updated:
		emit_signal("ghost_updated", ghost_pos)


func _move(dir:Vector2) -> bool:
	if not current:
		return true

	if detect_collision(current, dir):
		return false

	current.pos += dir
	emit_signal("moved", current)

	return true


func _is_completed_line(line_cells:Dictionary) -> bool:
	return _count_empty_cells(line_cells) == 0


func _is_empty_line(line_cells:Dictionary) -> bool:
	return _count_empty_cells(line_cells) == line_cells.size()


func _count_empty_cells(line_cells:Dictionary) -> int:
	var n_empty:int = 0

	for cell_idx in line_cells:
		if line_cells[cell_idx] == Cells.EMPTY:
			n_empty += 1

	return n_empty


func _get_line(y:int) -> Dictionary:
	var ret:Dictionary = {}

	for x in range(1, Width - 1):
		var idx:int = y * Width + x
		ret[idx] = cells[idx]

	return ret


func pretty_print(title:String) -> void:
	var s:String = ""

	# print title:
	#	- truncate if too long
	var m:int = Width - 2
	var p:int = m - title.length()
	if p < 0:
		title = title.substr(0, m)
	#	- add '-' paddings
	var l:int = title.length() + 2
	var c:String = "-"
	p = (Width - l) / 2
	s = c.repeat(p) + " " + title + " "
	p = Width - s.length()
	s += c.repeat(p)
	print("+" + s + "+")

	s = ""
	for cell in cells:
		s += " " if cell == Cells.EMPTY else "X"
		if s.length() >= Width:
			print("|" + s + "|")
			s = ""

	print("+" + "-".repeat(Width) + "+")
