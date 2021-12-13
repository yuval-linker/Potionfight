extends Potion

export(int) var total_dot_damage = 25
export(float) var dot_damage_time = 5.0
export(int) var total_dot_punch = 10
export(float) var dot_punch_time = 2.0

var damaged_enemy

func drink()->void:
	if player.is_network_master():
		player.ablaze_punches(total_dot_punch, dot_punch_time)
	.drink()

func damage_enemy(enemy)->bool:
	if is_network_master():
		.damage_enemy(enemy)
		damaged_enemy = enemy
		enemy.rpc("dot", total_dot_damage, dot_damage_time)
	return true

func _on_cooldown_finished()->void:
	if player.is_network_master():
		player.normal_punches()
	._on_cooldown_finished()
