class_name ScreenTransition
extends CanvasLayer

signal death_transition_complete()
signal spawn_transition_complete()
##range(0.01, 2.0)
@export var spawn_duration : float = 0.55
@export var respawn_duration : float = 0.55
@export var death_duration : float = 0.55
##range(0.0, 0.1)
@export var delay_duration : float = 0.2

var is_transitioning := false
var _transition_amount : float

var transition_amount : float = 0.0:
	get:
		return _transition_amount
	set(value):
		_set_transition_amount(value)

@onready var color_rect: ColorRect = $ColorRect
#@onready var audio_out: AudioStreamPlayer = $AudioOut
#@onready var audio_in: AudioStreamPlayer = $AudioIn
	
func _set_transition_amount(value: float) -> void:
	# Used to allow easier changing of shader param via tweens.
	_transition_amount = value
	color_rect.material.set_shader_parameter("amount", value)

func transition_out() -> void:
	is_transitioning = true
#	audio_out.play()
	transition_amount = 0.0
	
	if not get_tree(): return
	var tween = get_tree().create_tween()
	await tween.tween_property(self, "transition_amount", 1.0, death_duration)
	await TimeManager.sleep(delay_duration)

func transition_in(duration : float = spawn_duration) -> void:
	is_transitioning = true
#	audio_in.play()
	transition_amount = 1.0
	
	if not get_tree(): return
	var tween = get_tree().create_tween()
	await tween.tween_property(self, "transition_amount", 0.0, duration)

func _on_player_player_death(death_position):
	is_transitioning = true
	transition_out()
	await TimeManager.sleep(death_duration + delay_duration)
	is_transitioning = false
	death_transition_complete.emit()
	

func _on_player_player_spawned(spawn_position, initial):
	is_transitioning = true
	transition_in(spawn_duration if initial else respawn_duration)
	await TimeManager.sleep(spawn_duration)
	is_transitioning = false
