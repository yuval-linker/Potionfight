class_name BoxingPotion
extends Potion

var damaged_player: Player
onready var stun_timer: Timer = $StunTimer

const BASICS_BUFF: int = 10

func _ready() -> void:
	stun_timer.connect("timeout", self, "_on_stun_timeout")

func drink():
	player.empower_basics(BASICS_BUFF)
	.drink()

func damage_enemy(enemy)->bool:
	damaged_player = enemy
	enemy.damaged(player, damage, throw_origin.x)
	enemy.stun()
	stun_timer.start()
	disable()
	return false

func _on_cooldown_finished()->void:
	print("buff ended")
	player.weaken_basics(BASICS_BUFF)
	._on_cooldown_finished()

func _on_stun_timeout()->void:
	print("Stun Timeout")
	damaged_player.recover()
	_destroy()
