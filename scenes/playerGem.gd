extends PlayerTriggered

func _player_effect(player: PlayerController):
	player.give_bonus_jump()
	player.restore_dashs()

func _player_condition(player: PlayerController):
	return player.is_helpless()
