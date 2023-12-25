@icon("ldtk-level.svg")
@tool
class_name LDTKLevel
extends Node2D

@export var size: Vector2i
@export var fields: Dictionary
@export var neighbours: Array
@export var bg_color: Color

@onready var entities: LDTKEntityLayer = $Entities
@onready var tiles: TileMap = $Tilemaps8x8
var loaded_entities = []

func _ready() -> void:
	queue_redraw()
	load_tiles()

func _draw() -> void:
	if Engine.is_editor_hint():
		draw_rect(Rect2(Vector2.ZERO, size), bg_color, false, 2.0)
		
func load_tiles():
	for i in range(tiles.get_layers_count()):
#		print(tiles.get_layer_name(i))
		if(tiles.get_layer_name(i).ends_with("values")):
			tiles.set_layer_enabled(i,true)
			tiles.set_layer_modulate(i,Color(1,1,1,0))

func set_controller_type(controller_type: InputManager.ControllerType):
	for i in range(tiles.get_layers_count()):
		if(tiles.get_layer_name(i).begins_with("Gamepad")):
			tiles.set_layer_enabled(i,controller_type == InputManager.ControllerType.GAMEPAD)
		if(tiles.get_layer_name(i).begins_with("Keyboard")):
			tiles.set_layer_enabled(i,controller_type == InputManager.ControllerType.KEYBOARD)
			
func reload_room():
	unload_room()
	load_room()
	
func unload_room():
	unload_entities()
	
func load_room():
	set_controller_type(InputManager.get_controller_type())
	load_entities()
	
func load_entities():
	for entity in entities.entities:
		var scene: Resource = load("res://scenes/entities/" + entity.identifier.to_lower() + ".tscn")
		var node: Node = scene.instantiate()
		node.position = entity.position
		
		loaded_entities.append(node)
		call_deferred("add_child", node)
		
func unload_entities():
	for entity in loaded_entities:
		if(entity != null): entity.queue_free()
	loaded_entities.clear()
