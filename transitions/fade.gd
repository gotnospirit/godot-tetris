extends Node2D


func set_dimension(dim:Vector2) -> void:
	$ColorRect.rect_min_size = dim


# opacity: 0 -> 1
func fade_in(color:Color, duration:float, callback:FuncRef=null) -> void:
	$ColorRect.color = color
	_fade(0, 1, duration, callback)


# opacity: 1 -> 0
func fade_out(color:Color, duration:float, callback:FuncRef=null) -> void:
	$ColorRect.color = color
	_fade(1, 0, duration, callback)


func _fade(start:float, end:float, duration:float, cb:FuncRef=null) -> void:
	var tween:Tween = $ColorRect/Tween
	tween.interpolate_property($ColorRect, "modulate:a", start, end, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	if cb != null:
		tween.connect("tween_completed", self, "_on_tween_completed", [cb], CONNECT_ONESHOT)
	tween.start()


func _on_tween_completed(_o:Object, _key:NodePath, cb:FuncRef) -> void:
	cb.call_func()
