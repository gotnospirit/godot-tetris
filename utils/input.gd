class_name UtilsInput

const AxisLabels = [
	"Left Stick Left",
	"Left Stick Right",
	"Left Stick Up",
	"Left Stick Down",
	"Right Stick Left",
	"Right Stick Right",
	"Right Stick Up",
	"Right Stick Down",
	"", "", "", "",
	"", " L2",
	"", " R2"
]


static func _get_axis_label(event:InputEventJoypadMotion) -> String:
	var label_idx:int = 2 * event.axis
	if event.axis_value >= 0:
		label_idx += 1
	return AxisLabels[label_idx]


static func GetKeyNames(action_name:String) -> PoolStringArray:
	var ret:PoolStringArray = []
	var has_joypad_connected:bool = Input.get_connected_joypads().size() > 0

	for action in InputMap.get_action_list(action_name):
		if action is InputEventJoypadButton:
			if !has_joypad_connected:
				continue

			ret.append(Input.get_joy_button_string(action.button_index))
		elif action is InputEventJoypadMotion:
			if !has_joypad_connected:
				continue

			var label_str:String = _get_axis_label(action)
			if "" != label_str:
				ret.append(label_str)
		elif action is InputEventKey:
			ret.append(OS.get_scancode_string(action.physical_scancode))
		else:
			push_error(str(action))

	return ret
