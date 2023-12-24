extends Control

@export var input_escape : String = "escape"

func _input(_event):
	if _event.is_action_pressed(input_escape):
		quit_game()
		
func quit_game():
	get_tree().quit()
