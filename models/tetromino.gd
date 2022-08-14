class_name Tetromino

enum Types {
	TetriminoI,
	TetriminoZ,
	TetriminoS,
	TetriminoO,
	TetriminoT,
	TetriminoJ,
	TetriminoL,
}
enum Rotation { 
	ZERO, 			# 0 degrees
	QUARTER_1,		# 90 degrees
	QUARTER_2,		# 180 degrees
	QUARTER_3		# 270 degrees
}

const MaxWidth:int = 4
const Shapes:Array = [
	"  X   X   X   X ",
	"  X XX X ",
	" X  XX  X",
	"XXXX",
	" X XX  X ",
	" X  X XX ",
	" X  X  XX",
]
const ShapeWidths:Array = [
	4,
	3,
	3,
	2,
	3,
	3,
	3,
]
const Colors:Array = [
	Color8(43, 172, 226),
	Color8(238, 39, 51),
	Color8(78, 183, 72),
	Color8(253, 225, 0),
	Color8(146, 43, 140),
	Color8(0, 90, 157),
	Color8(248, 150, 34),
]

var desc:String
var type:int = -1
var rotation:int = -1
var pos:Vector2
var color:Color
var width:int = -1
var height:int = -1


func _init(tp:int):
	type = tp
	rotation = Rotation.ZERO
	pos = Vector2.ZERO
	color = Colors[tp]
	width = ShapeWidths[tp]
	height = width
	desc = _GetRotatedDesc(Shapes[tp], width, rotation)


func get_length() -> int:
	return desc.length()


func is_empty(idx:int) -> bool:
	return " " == desc[idx]


func rotate(r:int) -> void:
	rotation = r
	desc = _GetRotatedDesc(Shapes[type], ShapeWidths[type], r)
	width = ShapeWidths[type]
	height = width


func pretty_print() -> void:
	_PrettyPrint(desc, width)


func get_preview() -> Tetromino:
	var ret:Tetromino = get_script().new(type)
	ret._shrink()
	return ret


func _shrink() -> void:
	# locate the empty lines
	var line_to_remove:Array = _locate_empty(true)
	# locate the empty columns
	var column_to_remove:Array = _locate_empty(false)
	var w:int = ShapeWidths[type]

	# mark the chars we want to remove
	for y in line_to_remove:
		for x in range(w):
			desc[y * w + x] = "R"

	for x in column_to_remove:
		for y in range(w):
			desc[y * w + x] = "R"

	desc = desc.split("R", false).join("")
	width = w - column_to_remove.size()
	height = w - line_to_remove.size()


func _locate_empty(line_scan:bool) -> Array:
	var ret:Array = []
	var w:int = ShapeWidths[type]

	for x in range(w):
		var empty:bool = true

		for y in range(w):
			var idx = x * w + y if line_scan else y * w + x

			if not is_empty(idx):
				empty = false
				break

		if not empty:
			continue

		ret.append(x)

	return ret


static func _PrettyPrint(s:String, w:int) -> void:
	var tmp:String = ""

	print("+" + "-".repeat(w) + "+")
	for ch in s:
		tmp += ch
		if tmp.length() >= w:
			print("|" + tmp + "|")
			tmp = ""
	print("+" + "-".repeat(w) + "+")


static func _GetRotatedDesc(s:String, w:int, r:int) -> String:
	if r == Rotation.ZERO:
		# get a copy of the original
		return s.strip_escapes()

	var ret:String = " ".repeat(s.length())

	for idx in range(s.length()):
		var ri:int = _GetIndex(idx % w, int(idx / w), w, r)
		ret[ri] = s[idx]

	return ret


static func _GetIndex(x:int, y:int, w:int, r:int) -> int:
	var ret:int = 0

	match r:
		Rotation.ZERO:
			ret = y * w + x
		Rotation.QUARTER_1:
			ret = (w - 1) - y + (x * w)
		Rotation.QUARTER_2:
			ret = (w * w) - 1 - (y * w) - x
		Rotation.QUARTER_3:
			ret = w * (w - 1) + y - (x * w)

	return ret
