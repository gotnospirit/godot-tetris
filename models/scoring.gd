class_name Scoring

var score:int = -1
var level:int = -1
var lines:int = -1
var combo:int = -1

signal updated


func _init():
	score = 0
	level = 1
	lines = 0
	combo = -1


func update(nb_cleared_lines:int, perfect_clear:bool = false, nb_soft:int = 0, nb_sonic:int = 0) -> void:
	if nb_cleared_lines <= 0:
		combo = -1
		return

	combo += 1

	var nb_points:int

	match nb_cleared_lines:
		1:	# single
			nb_points = 800 if perfect_clear else 100
		2:	# double
			nb_points = 1200 if perfect_clear else 300
		3:	# triple
			nb_points = 1800 if perfect_clear else 500
		4:	# tetris
			nb_points = 2000 if perfect_clear else 800

	score += nb_points * level
	score += nb_soft * 1
	score += nb_sonic * 2
	score += combo * 50 * level

	var required_lines:int = 10 * level

	if lines + nb_cleared_lines >= required_lines:
		level += 1

	lines += nb_cleared_lines

	emit_signal("updated", score, lines, level)
