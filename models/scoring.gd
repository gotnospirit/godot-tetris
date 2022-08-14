class_name Scoring

var score:int = -1
var level:int = -1
var lines:int = -1

signal updated


func _init():
	score = 0
	level = 1
	lines = 0


func update(nb_cleared_lines:int, perfect_clear:bool, nb_soft:int, nb_sonic:int) -> void:
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

	lines += nb_cleared_lines
	score += nb_points * level
	score += nb_soft * 1
	score += nb_sonic * 2

	emit_signal("updated", score, lines, level)
