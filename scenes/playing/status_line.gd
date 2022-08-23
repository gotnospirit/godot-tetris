extends Control

export (String) var text setget _set_text
export (int) var count setget _set_count


func get_width() -> int:
	return $HBoxContainer/Label.get_minimum_size().x + $HBoxContainer.get_minimum_size().x + $HBoxContainer/Count.get_minimum_size().x


func get_height() -> int:
	return $HBoxContainer/Count.get_minimum_size().y


func _set_text(value:String) -> void:
	$HBoxContainer/Label.text = value + ":"


func _set_count(value:int) -> void:
	if value <= 9999999:
		$HBoxContainer/Count.text = str(value)
