extends "res://Scripts/Potions/Potion.gd"

signal teleport(position)

func drink() -> void:
	.drink()
	# Make player intangible with collision layers and masks

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("platforms"):
		player.position = global_position
		queue_free()

func _on_cooldown_finished() -> void:
	# Make player go tangible
	._on_cooldown_finished()
