extends Node

func sleep(s):
	await get_tree().create_timer(s).timeout
	return true
