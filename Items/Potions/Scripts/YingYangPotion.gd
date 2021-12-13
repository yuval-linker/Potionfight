extends Potion

const HEAL_AMOUNT: int = 20

func drink()->void:
	.drink()
	if player.is_network_master():
		player.healed(HEAL_AMOUNT)
	_destroy()
