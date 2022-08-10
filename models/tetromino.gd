class_name Tetromino

const Width:int = 4

const Types:Array = [
	"  X   X   X   X ", # I-Tetrimino
	"  X  XX  X      ", # Z-Tetrimino
	" X   XX   X     ", # S-Tetrimino
	"     XX  XX     ", # O-Tetrimino
	"  X  XX   X     ", # T-Tetrimino
	"  X   X  XX     ",	# J-Tetrimino
	" X   X   XX     ", # L-Tetrimino
]

enum Rotation { 
	ZERO, 			# 0 degrees
	QUARTER_1,		# 90 degrees
	QUARTER_2,		# 180 degrees
	QUARTER_3		# 270 degrees
}


static func get_index(x:int, y:int, r:int) -> int:
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
