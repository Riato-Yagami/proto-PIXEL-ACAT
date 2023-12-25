extends Node2D
class_name ShineTriggered

var activated:= true
@export var cooldown: int = 1
@onready var sprite: Sprite2D = $Sprite

func _shine_trigger(player: PlayerController):
	if(activated): 
		_desactivate()
		_shine_effect(player)

func _desactivate():
	activated = false
	sprite.visible = false
	await TimeManager.sleep(cooldown)
	_activate()

func _activate():
	sprite.visible = true
	activated = true

func _shine_effect(player: PlayerController):
	pass
