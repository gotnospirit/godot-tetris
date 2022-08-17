extends AudioStreamPlayer


func fade_in(duration:float = 2.0, callback:FuncRef=null) -> void:
	_animate("fade_in", duration, callback)


func fade_out(duration:float = 2.0, callback:FuncRef=null) -> void:
	_animate("fade_out", duration, callback)


func _animate(name:String, duration:float, cb:FuncRef=null):
	var speed:float = $AnimationPlayer.get_animation(name).length / duration
	$AnimationPlayer.connect("animation_finished", self, "_on_animation_finished", [cb], CONNECT_ONESHOT)
	$AnimationPlayer.play(name, -1, speed)


func start(s:AudioStream) -> void:
	stream = s
	volume_db = 0.0
	play(0)


func stop() -> void:
	if playing:
		stop()


func _on_animation_finished(_anim_name:String, cb:FuncRef) -> void:
	if cb:
		cb.call_func()
