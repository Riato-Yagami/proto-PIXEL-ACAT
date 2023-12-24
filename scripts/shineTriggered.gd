extends Node2D
class_name ShineTriggered

var activated:= true
@export var cooldown: int = 1
@onready var sprite: Sprite2D = $Sprite

func shine_trigger(player: PlayerController):
	if(activated): 
		desactivate()
		shine_effect(player)

func desactivate():
	activated = false
	sprite.visible = false
	await TimeManager.sleep(cooldown)
	activate()

func activate():
	sprite.visible = true
	activated = true

func shine_effect(player: PlayerController):
	pass
