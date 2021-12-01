class_name SpacePotion
extends Potion


func drink() -> void:
	.drink()
	player.make_intangible()
	# Make player intangible with collision layers and masks

# Teleport player to position
func env_effect(platform)->void:
	player.enable_raycasts()
	player.position = position
	player.position.y -= 16
	

func _on_cooldown_finished() -> void:
	# Make player go tangible
	player.make_tangible()
	._on_cooldown_finished()
