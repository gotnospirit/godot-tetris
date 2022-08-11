class_name Tetromino

const Width:int = 4

const Types:Array = [
	"  X   X   X   X ",		# I-Tetrimino
	"  X  XX  X      ",		# Z-Tetrimino
	" X   XX   X     ",		# S-Tetrimino
	"     XX  XX     ",		# O-Tetrimino
	"  X  XX   X     ",		# T-Tetrimino
	"  X   X  XX     ",		# J-Tetrimino
	" X   X   XX     ",		# L-Tetrimino
]

const Colors:Array = [
	Color8(43, 172, 226),	# I-Tetrimino
	Color8(238, 39, 51),	# Z-Tetrimino
	Color8(78, 183, 72),	# S-Tetrimino
	Color8(253, 225, 0),	# O-Tetrimino
	Color8(146, 43, 140),	# T-Tetrimino
	Color8(0, 90, 157),		# J-Tetrimino
	Color8(248, 150, 34),	# L-Tetrimino
]

enum Rotation { 
	ZERO, 			# 0 degrees
	QUARTER_1,		# 90 degrees
	QUARTER_2,		# 180 degrees
	QUARTER_3		# 270 degrees
}

var desc:String
var type:int = -1
var rotation:int = -1
var cell_x:int = -1
var cell_y:int = -1
var color:Color
var width:int = -1
var height:int = -1


func _init(tp:int, r:int, x:int, y:int):
	type = tp
	rotation = r
	cell_x = x
	cell_y = y
	color = Colors[tp]
	width = Width
	height = Width
	desc = GetRotatedDesc(Types[tp], r)


func shrink() -> void:
	# locate the empty lines
	var line_to_remove:Array = _locate_empty(Width, true)

	var h:int = Width - line_to_remove.size()

	# locate the empty columns
	var column_to_remove:Array = _locate_empty(h, false)

	# mark the chars we want to remove
	for y in line_to_remove:
		for x in range(Width):
			desc[y * Width + x] = "R"

	for x in column_to_remove:
		for y in range(Width):
			desc[y * Width + x] = "R"

	desc = desc.split("R", false).join("")
	width = Width - column_to_remove.size()
	height = h


func get_length() -> int:
	return desc.length()


func is_empty(idx:int) -> bool:
	return " " == desc[idx]


func pretty_print() -> void:
	PrettyPrint(desc, width)


func _locate_empty(max_y:int, line_scan:bool) -> Array:
	var ret:Array = []
	for x in range(Width):
		var empty:bool = true
		for y in range(max_y):
			var idx = x * Width + y if line_scan else y * Width + x
			if not is_empty(idx):
				empty = false
				break

		if not empty:
			continue

		ret.append(x)
	return ret


static func Debug() -> void:
	for t in range(Types.size()):
		for r in Rotation:
			print(str(90 * Rotation[r]) + " deg")
			var d = GetRotatedDesc(Types[t], Rotation[r])
			PrettyPrint(d, Width)
		print("------------")


static func PrettyPrint(s:String, w:int) -> void:
	var tmp:String = ""

	print("+" + "-".repeat(w) + "+")
	for ch in s:
		tmp += ch
		if tmp.length() >= w:
			print("|" + tmp + "|")
			tmp = ""
	print("+" + "-".repeat(w) + "+")


static func GetRotatedDesc(s:String, r:int) -> String:
	if r == Rotation.ZERO:
		# unsure we get a copy of the original
		return s.strip_escapes()

	var ret:String = " ".repeat(s.length())
	for idx in range(s.length()):
		var ri:int = GetIndex(idx % Width, int(idx / Width), r)
		ret[ri] = s[idx]
	return ret


static func GetIndex(x:int, y:int, r:int) -> int:
	var ret:int = 0
	match r:
		Rotation.ZERO:
			ret = y * Width + x
		Rotation.QUARTER_1:
			ret = Width * (Width - 1) + y - (x * Width)
		Rotation.QUARTER_2:
			ret = (Width * Width) - 1 - (y * Width) - x
		Rotation.QUARTER_3:
			ret = (Width - 1) - y + (x * Width)
	return ret
