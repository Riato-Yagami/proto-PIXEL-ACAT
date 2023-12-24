extends Node2D

@onready var DEFAULT_WORLD = $level_001
@export var current_world : LDTKWorld = DEFAULT_WORLD

func _ready():
	if !current_world: current_world = DEFAULT_WORLD
	add_world_maps_area(current_world)

func add_world_maps_area(world: LDTKWorld):
	for map in world.get_children():
		add_map_area(map)
		
func add_map_area(map: LDTKLevel):
	var map_area = Area2D.new()
	map_area.name = map.name + "_area"
	map_area.set_collision_layer_value(2,true)
	map_area.set_collision_layer_value(1,false)
#	map_area.set_collision_mask_value(1,false)
	var area_collider = CollisionShape2D.new()
	var collider_shape = RectangleShape2D.new()
	collider_shape.size = map.size
	area_collider.set_shape(collider_shape)
	map_area.add_child(area_collider)
	area_collider.position = map.size * 0.5
	map.add_child(map_area)
