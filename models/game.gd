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

signal status_updated
signal next_selected
signal spawned
signal moved
signal cells_updated
signal rotated


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
	current.pos = Vector2((Width - current.width) / 2, -current.height)

	if detect_collision(current, Vector2.DOWN):
		current = null
		return false

	emit_signal("spawned", current)
	return true


func move_left() -> void:
	_move(Vector2.LEFT)


func move_right() -> void:
	_move(Vector2.RIGHT)


func falldown() -> bool:
	return _move(Vector2.DOWN)


func _move(dir:Vector2) -> bool:
	if current:
		if detect_collision(current, dir):
			return true

		var old_y:int = current.pos.y
		current.pos += dir
		emit_signal("moved", current, old_y)

	return false


func rotate() -> void:
	if current:
		# no need to rotate a square
		if current.type == Tetromino.Types.TetriminoO:
			return

		var new_rotation:int = Tetromino.Rotation.ZERO
		match current.rotation:
			Tetromino.Rotation.ZERO:
				new_rotation = Tetromino.Rotation.QUARTER_1
			Tetromino.Rotation.QUARTER_1:
				new_rotation = Tetromino.Rotation.QUARTER_2
			Tetromino.Rotation.QUARTER_2:
				new_rotation = Tetromino.Rotation.QUARTER_3

		var old_rotation:int = current.rotation
		current.rotate(new_rotation)

		if detect_collision(current, Vector2.ZERO):
			# collision occured -> revert rotation
			current.rotate(old_rotation)
			return

		emit_signal("rotated", current)


func consolidate() -> void:
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

	emit_signal("cells_updated")


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
		# We make sure it's in bounds, so we can get
		# a grid index for this cell
		if cell_y + py >= 0 and cell_y + py < Height:
			var fi:int = (cell_y + py) * Width + (cell_x + px)

			if cells[fi] != Cells.EMPTY:
#				print("cell collision")
				return true

	return false


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
