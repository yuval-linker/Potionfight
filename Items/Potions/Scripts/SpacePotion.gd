class_name SpacePotion
extends Potion


func drink() -> void:
	.drink()
	if player.is_network_master():
		# Make player intangible with collision layers and masks
		player.make_intangible()

# Teleport player to position
func env_effect(_platform)->bool:
	if player.is_network_master():
		player.enable_raycasts()
		player.position = position
		player.position.y -= 16
	return true
	

func _on_cooldown_finished() -> void:
	# Make player go tangible
	if player.is_network_master():
		player.make_tangible()
	._on_cooldown_finished()
