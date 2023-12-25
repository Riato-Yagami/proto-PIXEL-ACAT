extends CharacterBody2D

class_name PlayerController

signal jumped(is_ground_jump: bool)
signal hit_ground()
signal player_death(death_position: Vector2)
signal player_spawned(spawn_position: Vector2, initial: bool)

@export var player_camera: Node
@export var player_spawn: Node
@export var player_animation: AnimatedSprite2D

var is_dead := false

var current_room_area: Area2D
var new_room_area: Area2D

@export var out_of_bound_delay : float = 0.1
@onready var out_of_bound_timer = Timer.new()
var is_out_of_bound := true

@export_group("Controls")

@export var input_up : String = "look_up"
@export var input_down : String = "look_down"
@export var input_left : String = "move_left"
@export var input_right : String = "move_right"
@export var input_special : String = "special"
@export var input_jump : String = "jump"
@export var input_reset : String = "reset"
@export var input_attack : String = "attack"

@export_group("Jump")

const DEFAULT_MAX_JUMP_HEIGHT = 60
const DEFAULT_MIN_JUMP_HEIGHT = 20
const DEFAULT_DOUBLE_JUMP_HEIGHT = 60
const DEFAULT_JUMP_DURATION = 0.28

const DEFAULT_JUMP_SQUAT_DURATION = 0.1

var _max_jump_height: float = DEFAULT_MAX_JUMP_HEIGHT
## The max jump height in pixels (holding jump).
@export var max_jump_height: float = DEFAULT_MAX_JUMP_HEIGHT: 
	get:
		return _max_jump_height
	set(value):
		_max_jump_height = value
	
		default_gravity = calculate_gravity(_max_jump_height, jump_duration)
		jump_velocity = calculate_jump_velocity(_max_jump_height, jump_duration)
		double_jump_velocity = calculate_jump_velocity2(double_jump_height, default_gravity)
		release_gravity_multiplier = calculate_release_gravity_multiplier(
				jump_velocity, min_jump_height, default_gravity)
			

var _min_jump_height: float = DEFAULT_MIN_JUMP_HEIGHT
## The minimum jump height (tapping jump).
@export var min_jump_height: float = DEFAULT_MIN_JUMP_HEIGHT: 
	get:
		return _min_jump_height
	set(value):
		_min_jump_height = value
		release_gravity_multiplier = calculate_release_gravity_multiplier(
				jump_velocity, min_jump_height, default_gravity)

var _double_jump_height: float = DEFAULT_DOUBLE_JUMP_HEIGHT
## The height of your jump in the air.
@export var double_jump_height: float = DEFAULT_DOUBLE_JUMP_HEIGHT:
	get:
		return _double_jump_height
	set(value):
		_double_jump_height = value
		double_jump_velocity = calculate_jump_velocity2(double_jump_height, default_gravity)
		

var _jump_duration: float = DEFAULT_JUMP_DURATION

## How long it takes to get to the peak of the jump in seconds.
@export var jump_duration: float = DEFAULT_JUMP_DURATION:
	get:
		return _jump_duration
	set(value):
		_jump_duration = value
	
		default_gravity = calculate_gravity(max_jump_height, jump_duration)
		jump_velocity = calculate_jump_velocity(max_jump_height, jump_duration)
		double_jump_velocity = calculate_jump_velocity2(double_jump_height, default_gravity)
		release_gravity_multiplier = calculate_release_gravity_multiplier(
				jump_velocity, min_jump_height, default_gravity)
				

var _jump_squat_duration: float = DEFAULT_JUMP_SQUAT_DURATION

## How long you have to release jump for small jump in binary jump mode
@export var jump_squat_duration: float = DEFAULT_JUMP_DURATION:
	get:
		return _jump_squat_duration
	set(value):
		_jump_squat_duration = value
		
## Multiplies the gravity by this while falling.
@export var falling_gravity_multiplier = 1.5
## Amount of jumps allowed before needing to touch the ground again. Set to 2 for double jump.
@export var jump_count = 1
@export var max_acceleration = 3600
@export var friction = 20
@export var can_hold_jump : bool = false
@export var binary_jump : bool = true
## You can still jump this many seconds after falling off a ledge.
@export var coyote_time : float = 0.1
## Pressing jump this many seconds before hitting the ground will still make you jump.
## Only neccessary when can_hold_jump is unchecked.
@export var jump_buffer : float = 0.1


# These will be calcualted automatically
# Gravity will be positive if it's going down, and negative if it's going up
var default_gravity : float
var jump_velocity : float
var double_jump_velocity : float
# Multiplies the gravity by this when we release jump
var release_gravity_multiplier : float

var jumps_left : int
var holding_jump := false

enum JumpType {NONE, GROUND, AIR}
## The type of jump the player is performing. Is JumpType.NONE if they player is on the ground.
var current_jump_type: JumpType = JumpType.NONE

enum DashType {NONE, HORIZONTAL, OMNIDIRECTIONAL}
var current_dash_type: DashType = DashType.NONE
# Used to detect if player just hit the ground
var _was_on_ground: bool

var acc = Vector2()

# coyote_time and jump_buffer must be above zero to work. Otherwise, godot will throw an error.
@onready var is_coyote_time_enabled = coyote_time > 0
@onready var is_jump_buffer_enabled = jump_buffer > 0
@onready var coyote_timer = Timer.new()
@onready var jump_buffer_timer = Timer.new()
@onready var jump_squat_timer = Timer.new()

var have_bonus_jump := false

@export_group("Special")

@export var helpless_state_enabled:= true

@export_group("Horizontal Dash")
var holding_special := false

enum Stance {NEUTRAL, UP, DOWN, LEFT, RIGHT}
var current_stance: Stance = Stance.NEUTRAL
var special_stance: Stance = Stance.NEUTRAL

enum Direction {LEFT, RIGHT}
var current_direction: Direction = Direction.RIGHT

@export var h_dash_duration: float = 0.1
@export var h_dash_speed: float = 700
@export var h_dash_pause_duration: float = 0.1
@export var h_dash_count: int = 1

@onready var h_dash_timer = Timer.new()
@onready var h_dash_pause_timer = Timer.new()

var h_dash_left : int

@export_group("Omnidirectional  Dash")
const DEFAULT_O_DASH_DURATION = 0.1
var o_dash_direction = Vector2(0,0)

@export var o_dash_duration: float = 0.2
@export var o_dash_pause_duration: float = 0.25 
@export var o_dash_speed: float = 250
@export var o_dash_count: int = 1

@onready var o_dash_timer = Timer.new()
@onready var o_dash_pause_timer = Timer.new()

var o_dash_left : int

@export var o_dash_fire_sprite: Node

@export_group("Plasma Gun")

@export var laser_scene: Resource
@export var can_hold_shoot:= true

@export_group("Shine")
@export var shine: Node2D
@export var shine_gravity_mutliplicator: float = 0.1

@export_group("Attack")
@export var attack_collision : CollisionShape2D
@export var attack_duration : float = 1.0
var is_attacking := false

var is_animation_locked := false

func _init():
	default_gravity = calculate_gravity(max_jump_height, jump_duration)
	jump_velocity = calculate_jump_velocity(max_jump_height, jump_duration)
	double_jump_velocity = calculate_jump_velocity2(double_jump_height, default_gravity)
	release_gravity_multiplier = calculate_release_gravity_multiplier(
			jump_velocity, min_jump_height, default_gravity)


func _ready():
	if is_coyote_time_enabled:
		add_child(coyote_timer)
		coyote_timer.wait_time = coyote_time
		coyote_timer.one_shot = true
	
	if is_jump_buffer_enabled:
		add_child(jump_buffer_timer)
		jump_buffer_timer.wait_time = jump_buffer
		jump_buffer_timer.one_shot = true
		
	if binary_jump:
		add_child(jump_squat_timer)
		jump_squat_timer.wait_time = jump_squat_duration
		jump_squat_timer.one_shot = true
		
	add_child(h_dash_timer)
	h_dash_timer.wait_time = h_dash_duration + h_dash_pause_duration
	h_dash_timer.one_shot = true
	
	add_child(h_dash_pause_timer)
	h_dash_pause_timer.wait_time = h_dash_pause_duration
	h_dash_pause_timer.one_shot = true
	
	add_child(o_dash_timer)
	o_dash_timer.wait_time = o_dash_duration + o_dash_pause_duration
	o_dash_timer.one_shot = true
	
	add_child(o_dash_pause_timer)
	o_dash_pause_timer.wait_time = o_dash_pause_duration
	o_dash_pause_timer.one_shot = true
	
	add_child(out_of_bound_timer)
	out_of_bound_timer.wait_time = out_of_bound_delay
	out_of_bound_timer.one_shot = true
	
	spawn(true)


func _input(_event):
	if is_dead: 
		acc = Vector2.ZERO
		return
		
	acc.x = 0
	current_stance = Stance.NEUTRAL
	
	if Input.is_action_pressed(input_reset):
		kill_player()
		
	if Input.is_action_pressed(input_attack):
		if not is_helpless() and not using_special() and not is_attacking:
			attack()
		
	if Input.is_action_pressed(input_left):
		current_stance = Stance.LEFT
		current_direction = Direction.LEFT
		acc.x = -max_acceleration
	
	if Input.is_action_pressed(input_right):
		current_stance = Stance.RIGHT
		current_direction = Direction.RIGHT
		acc.x = max_acceleration
		
	if Input.is_action_pressed(input_up):
		current_stance = Stance.UP
		
	if Input.is_action_pressed(input_down):
		current_stance = Stance.DOWN
		
#	if Input.is_action_just_released(input_down):
#		if using_shine: end_shine()
		
	if Input.is_action_pressed(input_special):
		if not (holding_special or using_special() or is_helpless()):
			special()
		holding_special = true
	
	if Input.is_action_just_released(input_special):
		holding_special = false
		if using_shine(): end_shine()
	
	if Input.is_action_just_pressed(input_jump):
		holding_jump = true
		start_jump_buffer_timer()
		if (not can_hold_jump and can_ground_jump()) or can_double_jump() and not is_helpless():
			jump()
		
	if Input.is_action_just_released(input_jump):
		holding_jump = false


func _physics_process(delta):
	if is_coyote_timer_running() or (
		current_jump_type == JumpType.NONE 
		and current_dash_type == DashType.NONE):
			restore_jumps()
			restore_dashs()
	if is_feet_on_ground() and current_jump_type == JumpType.NONE:
		start_coyote_timer()
		
	# Check if we just hit the ground this frame
	if not _was_on_ground and is_feet_on_ground():
		current_jump_type = JumpType.NONE
		current_dash_type = DashType.NONE
		if is_jump_buffer_timer_running() and not can_hold_jump: 
			jump()
		
		hit_ground.emit()
	
	
	# Cannot do this in _input because it needs to be checked every frame
	if Input.is_action_pressed(input_jump):
		if can_ground_jump() and can_hold_jump:
			jump()
	
	var gravity = apply_gravity_multipliers_to(default_gravity)
	acc.y = gravity
	
	# Apply friction
	if using_shine():
		acc.y *= shine_gravity_mutliplicator
		velocity += acc * delta
		velocity.x = 0
	else:
		velocity += acc * delta
		velocity.x *= 1 / (1 + (delta * friction))
	
	if is_o_dash_timer_running():
		if is_o_dash_pause_timer_running():
			velocity.x = 0
			velocity.y = 0
			o_dash_direction = Vector2.ZERO
			if Input.is_action_pressed("move_left"): o_dash_direction.x = -1
			if Input.is_action_pressed("move_right"): o_dash_direction.x = 1
			if Input.is_action_pressed("look_up"): o_dash_direction.y = -1
			if Input.is_action_pressed("look_down"): o_dash_direction.y = 1
			
			var rotation_angle = atan2(o_dash_direction.x, -o_dash_direction.y)
			o_dash_fire_sprite.rotation = rotation_angle
		else:
			o_dash_fire_sprite.visible = false
			velocity= o_dash_speed * o_dash_direction.normalized()
			
	if is_h_dash_timer_running():
		velocity.y = 0
		if is_h_dash_pause_timer_running():
			velocity.x = 0
		else:
			velocity.x = h_dash_speed * (1 if special_stance == Stance.RIGHT else -1)
		
	_was_on_ground = is_feet_on_ground()
	
	if is_dead:
		velocity = Vector2.ZERO
		
	move_and_slide()
	
	player_animation.flip_h = current_direction == Direction.LEFT
	
func _process(delta):
	if velocity.x == 0: play_animation("idle")
	else: play_animation("walk")
	if velocity.y < 0 : play_animation("rise")
	elif velocity.y > 0 : play_animation("fall")
		
	if is_h_dash_timer_running(): play_animation("hdash")
	elif is_o_dash_timer_running(): play_animation("odash")
	
	if is_helpless():
		player_animation.self_modulate = Color(0,1.6,1)
	else:
		player_animation.self_modulate = Color(1,1,1)
		
	if is_out_of_bound and out_of_bound_timer.is_stopped():
		kill_player()

## Use this instead of coyote_timer.start() to check if the coyote_timer is enabled first
func start_coyote_timer():
	if is_coyote_time_enabled:
		coyote_timer.start()

## Use this instead of jump_buffer_timer.start() to check if the jump_buffer is enabled first
func start_jump_buffer_timer():
	if is_jump_buffer_enabled:
		jump_buffer_timer.start()
		
func start_jump_squat_timer():
	if binary_jump:
		jump_squat_timer.start()
		
func start_h_dash_timer():
	h_dash_timer.start()
	
func start_h_dash_pause_timer():
	h_dash_pause_timer.start()
	
func start_o_dash_timer():
	o_dash_timer.start()
	
func start_o_dash_pause_timer():
	o_dash_pause_timer.start()

func is_coyote_timer_running():
	return (is_coyote_time_enabled and not coyote_timer.is_stopped())
		
func is_jump_buffer_timer_running():
	return is_jump_buffer_enabled and not jump_buffer_timer.is_stopped()

func is_jump_squat_timer_running():
	return binary_jump and not jump_squat_timer.is_stopped()
	
func is_h_dash_timer_running():
	return not h_dash_timer.is_stopped()
	
func is_h_dash_pause_timer_running():
	return not h_dash_pause_timer.is_stopped()
	
func is_o_dash_timer_running():
	return not o_dash_timer.is_stopped()
	
func is_o_dash_pause_timer_running():
	return not o_dash_pause_timer.is_stopped()

func is_out_of_bound_timer_running():
	return not out_of_bound_timer.is_stopped()
	
func using_dash() -> bool:
	return is_h_dash_timer_running() or is_o_dash_timer_running()
	
func using_special() -> bool:
	return using_dash() or using_shine()
	
func can_ground_jump() -> bool:
	return jumps_left > 0 and current_jump_type == JumpType.NONE and is_coyote_timer_running()


func can_double_jump() -> bool:
	if have_bonus_jump: #jump given by gems
		return true
	
	if jumps_left <= 1 and jumps_left == jump_count:
		# Special case where you've fallen off a cliff and only have 1 jump. You cannot use your
		# first jump in the air
		return false
	
	if jumps_left > 0 and not is_feet_on_ground() and coyote_timer.is_stopped():
		return true
	
	return false


## Same as is_on_floor(), but also returns true if gravity is reversed and you are on the ceiling
func is_feet_on_ground() -> bool:
	if is_on_floor() and default_gravity >= 0:
		return true
	if is_on_ceiling() and default_gravity <= 0:
		return true
	return false


## Perform a ground jump, or a double jump if the character is in the air.
func jump():
	if using_dash(): return
	if using_shine(): end_shine()
	if can_double_jump():
		double_jump()
	else:
		ground_jump()
	have_bonus_jump = false
		
func special():
	special_stance = current_stance
	if (special_stance == Stance.LEFT or special_stance == Stance.RIGHT) and h_dash_left > 0:
		h_dash()
		return
	elif special_stance == Stance.NEUTRAL:
		shoot()
	elif special_stance == Stance.DOWN:
		start_shine()
	elif special_stance == Stance.UP:
		o_dash()
		
func h_dash():
	coyote_timer.stop()
	current_dash_type = DashType.HORIZONTAL
	h_dash_left -= 1
	start_h_dash_pause_timer()
	start_h_dash_timer()
	
func o_dash():
	coyote_timer.stop()
	current_dash_type = DashType.OMNIDIRECTIONAL
	o_dash_left -= 1
	o_dash_fire_sprite.visible = true
	start_o_dash_pause_timer()
	start_o_dash_timer()
	
func shoot():
	var laser_instance = laser_scene.instantiate()
	laser_instance.global_position = global_position
	laser_instance.current_direction = current_direction
	get_parent().add_child(laser_instance)
	
	if can_hold_shoot:
		holding_special = false
		
func start_shine():
	velocity.y = 0
	shine.start_shine()
	
func end_shine():
	shine.end_shine()
	
func using_shine() -> bool:
	return shine.in_shine

func give_bonus_jump():
	have_bonus_jump = true
	
func restore_jumps():
	have_bonus_jump = false
	jumps_left = jump_count
## Perform a double jump without checking if the player is able to.
func double_jump():
	if jumps_left == jump_count:
		# Your first jump must be used when on the ground.
		# If your first jump is used in the air, an additional jump will be taken away.
		jumps_left -= 1
	
	velocity.y = -double_jump_velocity
	current_jump_type = JumpType.AIR
	jumps_left -= 1
	jumped.emit(false)

func is_helpless():
	return (helpless_state_enabled 
	and (h_dash_left < 1 or o_dash_left < 1) 
	and not using_dash())
	
func restore_dashs():
#	print("restore dash")
	h_dash_left = h_dash_count
	o_dash_left = o_dash_count

## Perform a ground jump without checking if the player is able to.
func ground_jump():
	start_jump_squat_timer()
	velocity.y = -jump_velocity
	current_jump_type = JumpType.GROUND
	jumps_left -= 1
	coyote_timer.stop()
	jumped.emit(true)

func apply_gravity_multipliers_to(gravity) -> float:
	if velocity.y * sign(default_gravity) > 0: # If we are falling
		gravity *= falling_gravity_multiplier
	
	# if we released jump and are still rising
	elif velocity.y * sign(default_gravity) < 0:
		if not holding_jump: 
			if not current_jump_type == JumpType.AIR : # Always jump to max height when we are using a double jump
				if not binary_jump or is_jump_squat_timer_running():
					gravity *= release_gravity_multiplier # multiply the gravity so we have a lower jump
					
	return gravity
	
## Calculates the desired gravity from jump height and jump duration.  [br]
## Formula is from [url=https://www.youtube.com/watch?v=hG9SzQxaCm8]this video[/url] 
func calculate_gravity(p_max_jump_height, p_jump_duration):
	return (2 * p_max_jump_height) / pow(p_jump_duration, 2)

## Calculates the desired jump velocity from jump height and jump duration.
func calculate_jump_velocity(p_max_jump_height, p_jump_duration):
	return (2 * p_max_jump_height) / (p_jump_duration)

## Calculates jump velocity from jump height and gravity.  [br]
## Formula from 
## [url]https://sciencing.com/acceleration-velocity-distance-7779124.html#:~:text=in%20every%20step.-,Starting%20from%3A,-v%5E2%3Du[/url]
func calculate_jump_velocity2(p_max_jump_height, p_gravity):
	return sqrt(abs(2 * p_gravity * p_max_jump_height)) * sign(p_max_jump_height)

## Calculates the gravity when the key is released based off the minimum jump height and jump velocity.  [br]
## Formula is from [url]https://sciencing.com/acceleration-velocity-distance-7779124.html[/url]
func calculate_release_gravity_multiplier(p_jump_velocity, p_min_jump_height, p_gravity):
	var release_gravity = pow(p_jump_velocity, 2) / (2 * p_min_jump_height)
	return release_gravity / p_gravity

## Returns a value for friction that will hit the max speed after 90% of time_to_max seconds.  [br]
## Formula from [url]https://www.reddit.com/r/gamedev/comments/bdbery/comment/ekxw9g4/?utm_source=share&utm_medium=web2x&context=3[/url]
func calculate_friction(time_to_max):
	return 1 - (2.30259 / time_to_max)

## Formula from [url]https://www.reddit.com/r/gamedev/comments/bdbery/comment/ekxw9g4/?utm_source=share&utm_medium=web2x&context=3[/url]
func calculate_speed(p_max_speed, p_friction):
	return (p_max_speed / p_friction) - p_max_speed

func spawn(initial:= false):
	position = player_spawn.position
	is_out_of_bound = false
	load_room()
	player_spawned.emit(position, initial)
	is_dead = false
	
func load_room():
	if(current_room_area != null):
		var map: LDTKLevel = current_room_area.get_parent()
		map.reload_room()
	
func set_spawn(pos):
	player_spawn.position = pos
	
func attack():
	play_animation("attack")
	is_animation_locked = true
	is_attacking = true
	attack_collision.disabled = false
	await TimeManager.sleep(attack_duration)
	stop_attack()
	
func stop_attack():
	attack_collision.disabled = true
	is_animation_locked = false
	is_attacking = false
	
func play_animation(animation_name: String):
	if not is_animation_locked: player_animation.play(animation_name)
	
func _on_room_detector_area_entered(area: Area2D) -> void:
#	print("New area: " + area.name)
	if(current_room_area == null):
		enter_room_area(area)
		
	new_room_area = area

func _on_room_detector_area_exited(area: Area2D) -> void:
#	print("Leave area: " + area.name)
	if(new_room_area != area):
		exit_room_area(area)
		enter_room_area(new_room_area)
	elif(current_room_area == area):
		is_out_of_bound = true
		out_of_bound_timer.start()
		
func exit_room_area(area: Area2D):
	var map: LDTKLevel = area.get_parent()
	map.unload_room()
	
func enter_room_area(area: Area2D):
#	print("Player's entered: " + area.name)
	is_out_of_bound = false
	current_room_area = area
	var map: LDTKLevel = area.get_parent()
	map.load_room()
	var collision_shape: CollisionShape2D = area.get_child(0)
	var shape_size: Vector2 = collision_shape.shape.extents * 2
	var shape_position: Vector2 = collision_shape.global_position
	player_camera.change_room(shape_position, shape_size)
	
	set_spawn(position)
	
func kill_player():
	is_dead = true
	player_death.emit(position)
	
func _on_hit_box_area_entered(area: Area2D):
	var object : PlayerTriggered = area.get_parent()
#	print(object.name + " entered Player's hitbox")
	if(object._player_condition(self)):
		object._player_trigger(self)


func _on_hurt_box_body_entered(body: Node):
#	print(body.name + " entered Player's hurtbox")
	kill_player()


func _on_hurt_box_area_entered(area: Area2D):
	kill_player()


func _on_attack_hit_box_area_entered(area):
	var object : Node = area.get_parent()
	if object is Triggered:
		var trigger : Triggered = object
		trigger._trigger(self)

func _on_screen_transition_death_transition_complete():
	spawn()
