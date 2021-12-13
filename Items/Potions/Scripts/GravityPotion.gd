extends Potion

const SPEED_MOD = 1000
const JUMP_MOD = 100

func drink()->void:
	if player.is_network_master():
		player.light_body(JUMP_MOD)
	.drink()

func _on_cooldown_finished()->void:
	if player.is_network_master():
		player.heavy_body(JUMP_MOD)
	._on_cooldown_finished()

func damage_enemy(enemy)->bool:
	if is_network_master():
		enemy.rpc("damaged", player, damage, throw_origin.x, SPEED_MOD)
	return true
