@icon("ldtk-level.svg")
@tool
class_name LDTKLevel
extends Node2D

@export var size: Vector2i
@export var fields: Dictionary
@export var neighbours: Array
@export var bg_color: Color

@onready var entities: LDTKEntityLayer = $Entities

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	if Engine.is_editor_hint():
		draw_rect(Rect2(Vector2.ZERO, size), bg_color, false, 2.0)
		
func load_entities():
	for entity in entities.entities:
		var scene: Resource = load("res://scenes/entities/" + entity.identifier.to_lower() + ".tscn")
		var node: Node = scene.instantiate()
		node.position = entity.position
		call_deferred("add_child", node)

func unload_entities():
	pass
