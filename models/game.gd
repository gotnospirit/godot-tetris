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

signal status_updated


func _init():
	status = Status.INIT

	cells.resize(Width * Height)
	for i in range(Width * Height):
		var is_border:bool = (i % Width == 0) or (i % Width == Width - 1) or (int(i / Width) == Height - 1)
		cells[i] = Cells.BORDER if is_border else Cells.EMPTY


func get_size() -> Vector2:
	return Vector2(Width, Height)


func set_status(new_status:int) -> void:
	if new_status != status:
		status = new_status
		emit_signal("status_updated", new_status)


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
