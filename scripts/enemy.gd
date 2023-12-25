extends Triggered

# Called when the node enters the scene tree for the first time.
func _ready():
	_sprite.play("default")

func _effect(player: PlayerController) -> void:
	kill()
	
func kill():
	queue_free()
