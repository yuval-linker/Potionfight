class_name BoxingPotion
extends Potion

var damaged_player: Player
onready var stun_timer: Timer = $StunTimer

const BASICS_BUFF: int = 10

func _ready() -> void:
	var _err = stun_timer.connect("timeout", self, "_on_stun_timeout")

func drink():
	if player.is_network_master():
		player.empower_basics(BASICS_BUFF)
	.drink()

func damage_enemy(enemy)->bool:
	damaged_player = enemy
	if is_network_master():
		enemy.rpc("damaged", player, damage, throw_origin.x)
		enemy.rpc("stun")
	stun_timer.start()
	disable()
	return false

func _on_cooldown_finished()->void:
	print("buff ended")
	if player.is_network_master():
		player.weaken_basics(BASICS_BUFF)
	._on_cooldown_finished()

func _on_stun_timeout()->void:
	print("Stun Timeout")
	if is_network_master():
		damaged_player.rpc("recover")
	_destroy()
