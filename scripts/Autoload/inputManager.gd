extends Node

var player_count
var connected_joypads

const DEADZONE = 0.2

var current_device_id = 0

enum ControllerType {KEYBOARD, GAMEPAD}

var current_controller_type : ControllerType = ControllerType.KEYBOARD

func _ready():
	dectect_controlers()
	if connected_joypads:
		current_controller_type = ControllerType.GAMEPAD
	
func _input(event):
	if is_gamepad(event):
		current_controller_type = ControllerType.GAMEPAD
	else:
		current_controller_type = ControllerType.KEYBOARD
		
func get_controller_type() -> ControllerType:
	return current_controller_type
		
func is_gamepad(event) -> bool:
	if is_mouse(event): return current_controller_type == ControllerType.GAMEPAD
	else: return not is_keyboard(event) 
	
func is_keyboard(event):
	return event is InputEventKey
	
func is_mouse(event):
	return event is InputEventMouse
	
func device_id(event):
	if is_gamepad(event): return event.device + 1
	else: return 0
	
func dectect_controlers():
	connected_joypads = Input.get_connected_joypads()
	player_count = connected_joypads.size()
