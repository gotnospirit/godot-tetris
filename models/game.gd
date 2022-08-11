class_name Game

const Width:int = 12
const Height:int = 18
const Cells = {
	BORDER = 9,
	EMPTY = 0
}

enum Status { INIT, PLAYING, GAME_OVER }

var status:int
var cells:Array = []
var next:Tetromino = null
var current:Tetromino = null

signal status_updated
signal next_selected
signal spawned
signal moved
signal collision


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

	next = Tetromino.new(type, Tetromino.Rotation.ZERO)

	emit_signal("next_selected", next)


func spawn() -> void:
	if not next:
		push_error("Next tetromino not selected yet")
		return

	current = next
	select_next()
	current.shrink()
	current.pos = Vector2(Width / 2, -current.height)
	emit_signal("spawned", current)


func move_left() -> void:
	_move(Vector2.LEFT)


func move_right() -> void:
	_move(Vector2.RIGHT)


func falldown() -> void:
	_move(Vector2.DOWN)


func _move(dir:Vector2) -> void:
	if current:
		# stick inside the horizontal borders
		var new_pos:Vector2 = current.pos + dir
		if new_pos.x < 1 or new_pos.x >= Width - 2:
			return

		if not detect_collision(current, dir):
			var old_y:int = current.pos.y
			current.pos += dir
			emit_signal("moved", current, old_y)
		else:
			emit_signal("collision")


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

		# We only evaluate the cells who are inside the grid's view
		if cell_x + px >= 0 and cell_x + px < Width:
			var py:int = idx / t.width

			if cell_y + py >= 0 and cell_y + py < Height:
				# Translate into grid index
				var fi:int = (cell_y + py) * Width + (cell_x + px)

				if not t.is_empty(idx) and cells[fi] != Cells.EMPTY:
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
		s += "X" if cell == Cells.BORDER else " "
		if s.length() >= Width:
			print("|" + s + "|")
			s = ""

	print("+" + "-".repeat(Width) + "+")
