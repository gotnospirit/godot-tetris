extends Node2D

const ButtonWidth:int = 64
const PausedAlpha:float = .4


func set_paused(value:bool) -> void:
	for node in $Arrows.get_children() + $Rotations.get_children():
		if node.pause_mode != Node.PAUSE_MODE_STOP:
			continue

		node.modulate.a = PausedAlpha if value else 1.0


func get_height() -> int:
	return 2 * ButtonWidth * int(scale.y)


func _layout(width:int) -> void:
	var scale_factor:float = UtilsMobile.GetScale()

	# scale up textures
	scale *= scale_factor
	# scale down the given width
	$Rotations.position.x = width / scale_factor - (2 * ButtonWidth)
