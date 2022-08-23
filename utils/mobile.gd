class_name UtilsMobile


static func IsMobile() -> bool:
	return OS.has_touchscreen_ui_hint()


static func GetScale() -> float:
	var dpi:int = OS.get_screen_dpi()

	if dpi > 120:
		return ceil(dpi / 120)

	return 1.0


static func UpdatePanel(node:Panel, width:int = 2, radius:int = 6) -> void:
	var style = node.get_stylebox("panel", "")
	var scale:float = GetScale()

	# frame border width
	var border_width:int = width * scale

	style.border_width_top = border_width
	style.border_width_bottom = border_width
	style.border_width_left = border_width
	style.border_width_right = border_width

	# frame border radius
	var border_radius:int = radius * scale

	style.corner_radius_top_left = border_radius
	style.corner_radius_top_right = border_radius
	style.corner_radius_bottom_left = border_radius
	style.corner_radius_bottom_right = border_radius


static func GetFramePadding() -> int:
	var dft_value:int = 10
	var scale:float = GetScale()

	return int(dft_value * scale)
