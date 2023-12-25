extends Node2D
class_name PlayerTriggered

var activated:= true
@export var cooldown: int = 1
@onready var sprite: Sprite2D = $Sprite

func _player_trigger(player: PlayerController):
	if(activated): 
		_desactivate()
		_player_effect(player)

func _desactivate():
	activated = false
	sprite.visible = false
	await TimeManager.sleep(cooldown)
	_activate()

func _activate():
	sprite.visible = true
	activated = true
	
func _player_condition(player: PlayerController) -> bool:
	return true

func _player_effect(player: PlayerController) -> void:
	pass
