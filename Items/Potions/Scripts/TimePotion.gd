extends Potion

const SPEED_BUFF: int = 150
const SPEED_DEBUFF: int = 100

onready var debuff_timer = $DebuffTimer

var damaged_player

func _ready() -> void:
	debuff_timer.connect("timeout", self, "_on_debuff_finished")

func drink()->void:
	player.make_faster(SPEED_BUFF)
	print(player.modified_speed)
	.drink()

func damage_enemy(enemy)->bool:
	.damage_enemy(enemy)
	damaged_player = enemy
	damaged_player.make_slower(SPEED_DEBUFF)
	debuff_timer.start()
	disable()
	return false

func _on_cooldown_finished()->void:
	player.make_slower(SPEED_BUFF)
	._on_cooldown_finished()

func _on_debuff_finished()->void:
	damaged_player.make_faster(SPEED_DEBUFF)
	_destroy()
