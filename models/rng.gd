class_name Rng

var _rng:RandomNumberGenerator = RandomNumberGenerator.new()
var _bag:Array


func _init():
	_bag = _create_first_bag()


func pop() -> Tetromino:
	if _bag.empty():
		_bag = _create_bag()

	return Tetromino.new(_bag.pop_back())


func pretty_print() -> void:
	var s:PoolStringArray = PoolStringArray()

	for i in _bag:
		match i:
			Tetromino.Types.TetriminoI:
				s.append("I")
			Tetromino.Types.TetriminoZ:
				s.append("Z")
			Tetromino.Types.TetriminoS:
				s.append("S")
			Tetromino.Types.TetriminoO:
				s.append("O")
			Tetromino.Types.TetriminoT:
				s.append("T")
			Tetromino.Types.TetriminoJ:
				s.append("J")
			Tetromino.Types.TetriminoL:
				s.append("L")

	print("bag: ", s.join(" "))


func _create_first_bag() -> Array:
	# the first tetromino of the first bag is always I, J, L, or T
	var haystack:Array = [
		Tetromino.Types.TetriminoI,
		Tetromino.Types.TetriminoT,
		Tetromino.Types.TetriminoJ,
		Tetromino.Types.TetriminoL,
	]

	_rng.randomize()

	var first:int = haystack[_rng.randi_range(0, haystack.size() - 1)]
	var ret:Array = _create_bag(first)
	# we will "pop back", so the first tetromino must be the last appended
	ret.append(first)
	return ret


func _create_bag(except:int = -1) -> Array:
	var ret:Array = []
	var haystack:Array = [
		Tetromino.Types.TetriminoI,
		Tetromino.Types.TetriminoZ,
		Tetromino.Types.TetriminoS,
		Tetromino.Types.TetriminoO,
		Tetromino.Types.TetriminoT,
		Tetromino.Types.TetriminoJ,
		Tetromino.Types.TetriminoL,
	]

	if except != -1:
		haystack.erase(except)

	_rng.randomize()

	while not haystack.empty():
		var needle:int = _rng.randi_range(0, haystack.size() - 1)

		ret.push_back(haystack[needle])
		haystack.remove(needle)

	return ret
