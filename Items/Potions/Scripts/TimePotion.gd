extends Potion

const SPEED_BUFF: int = 230
const SPEED_DEBUFF: int = 100

onready var debuff_timer = $DebuffTimer

var damaged_player

func _ready() -> void:
	debuff_timer.connect("timeout", self, "_on_debuff_finished")

func drink()->void:
	if player.is_network_master() and player.modified_speed < player.UPPER_SPEED_CAP:
		player.make_faster(SPEED_BUFF)
		.drink()
	else:
		_destroy()

func damage_enemy(enemy)->bool:
	var _ret = .damage_enemy(enemy)
	damaged_player = enemy
	if is_network_master():
		damaged_player.rpc("make_slower", SPEED_DEBUFF)
	debuff_timer.start()
	disable()
	return false

func _on_cooldown_finished()->void:
	if player.is_network_master():
		player.make_slower(SPEED_BUFF)
	._on_cooldown_finished()

func _on_debuff_finished()->void:
	if is_network_master():
		damaged_player.rpc("make_faster", SPEED_DEBUFF)
	_destroy()
