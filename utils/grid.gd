class_name UtilsGrid


static func MoveInto(from:Node2D, to:Node2D) -> void:
	for node in from.get_children():
		# don't transfer invisible nodes
		if node.modulate.a == 0:
			node.queue_free()
			from.remove_child(node)
			continue

		var dup:ColorRect = node.duplicate()
		# remove from parent
		node.queue_free()
		from.remove_child(node)

		# add the duplicate to new parent
		# and don't forget to offset their position
		dup.rect_position += from.position
		to.add_child(dup)


static func RemoveLines(parent:Node2D, lines:Array, tile_size:int) -> void:
	for node in parent.get_children():
		var y:int = node.rect_position.y / tile_size

		if y in lines:
			node.queue_free()
			parent.remove_child(node)


static func MoveLines(parent:Node2D, lines:Dictionary, tile_size:int) -> void:
	for node in parent.get_children():
		var y:int = node.rect_position.y / tile_size

		if lines.has(y):
			node.rect_position.y = lines[y] * tile_size
