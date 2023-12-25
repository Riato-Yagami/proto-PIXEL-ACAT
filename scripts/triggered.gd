extends Node2D
class_name Triggered

var activated:= true
@export var _is_single_use := false
@export var _cooldown: int = 1
@onready var _sprite = $Sprite

func _trigger(player: PlayerController):
	if(activated): 
		_desactivate()
		_effect(player)

func _desactivate():
	activated = false
	_sprite.visible = false
	
	if not _is_single_use:
		await TimeManager.sleep(_cooldown)
		_activate()

func _activate():
	_sprite.visible = true
	activated = true
	
func _condition(player: PlayerController) -> bool:
	return true

func _effect(player: PlayerController) -> void:
	pass
