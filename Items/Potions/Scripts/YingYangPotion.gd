extends Potion

const HEAL_AMOUNT: int = 20
export(int) var yy_damage = 25

func _ready() -> void:
	damage = yy_damage

func drink()->void:
	.drink()
	player.healed(20)
	_destroy()
