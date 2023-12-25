extends Node2D

@onready var player: CharacterBody2D =  $".."
@export var sprite: Sprite2D
var nodes_in_hitbox: Array = []
var in_shine := false

func start_shine():
	in_shine = true
	sprite.visible = true
	trigger_nodes_in_hitbox()
	
func end_shine():
	in_shine = false
	sprite.visible = false

func trigger_nodes_in_hitbox():
	for node in nodes_in_hitbox:
#		print("triggering:" + node.name)
		node._shine_trigger(player)
	
func _on_hit_box_area_entered(area: Area2D) -> void:
	var object : ShineTriggered = area.get_parent()
#	print(object.name + " entered Player's shine hitbox")
	nodes_in_hitbox.append(object)
#	print(nodes_in_hitbox)
	
func _on_hit_box_area_exited(area):
	var object = area.get_parent()
#	print(object.name + " exited Player's shine hitbox")
	nodes_in_hitbox.erase(object)
	
