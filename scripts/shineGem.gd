extends ShineTriggered

func _shine_effect(player: PlayerController):
#	print("Gem Restoring Jumps")
	player.give_bonus_jump()
