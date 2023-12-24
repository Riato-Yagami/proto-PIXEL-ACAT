extends CharacterBody2D

const DEFAULT_LASER_SPEED = 1500
const LASER_LIFE_DURATION = 1

var _laser_speed: float = DEFAULT_LASER_SPEED

@export var laser_speed: float = DEFAULT_LASER_SPEED: 
	get: return _laser_speed
	set(value): _laser_speed = value
	
var _laser_life_duration: float = LASER_LIFE_DURATION
@export var laser_life_duration: float = LASER_LIFE_DURATION: 
	get: return _laser_life_duration
	set(value): _laser_life_duration = value
	
@onready var laser_life_timer = Timer.new()

enum Direction {LEFT, RIGHT}
var current_direction: Direction = Direction.RIGHT

func _ready():
	add_child(laser_life_timer)
	laser_life_timer.wait_time = laser_life_duration
	laser_life_timer.one_shot = true
	laser_life_timer.start()

func _process(delta):
	if laser_life_timer.is_stopped():
		destroy()

func _physics_process(delta):
	velocity = Vector2(laser_speed * (1 if current_direction == Direction.RIGHT else -1),0)
	move_and_slide()
	
func destroy():
	queue_free()
