class_name Potion
extends Area2D

const GRAVITY = 500

var player: KinematicBody2D
var linear_vel: Vector2 = Vector2.ZERO
var _disabled: bool = false
var throw_origin: Vector2
export(int) var damage = 10

onready var cooldown: Timer = $CooldownTimer
onready var sprite: Sprite = $Sprite
onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
# warning-ignore:return_value_discarded
	connect("body_entered", self, "_on_body_entered")
# warning-ignore:return_value_discarded
	cooldown.connect("timeout", self, "_on_cooldown_finished")

func _physics_process(delta: float) -> void:
	position += linear_vel * delta
	linear_vel.y += GRAVITY * delta

func throw(direction: Vector2) -> void:
	linear_vel = direction
	throw_origin = global_position

func drink() -> void:
	disable()
	cooldown.start()

# Override this function to apply an effect while damaging an enemy
func damage_enemy(enemy) -> bool:
	if is_network_master():
		enemy.rpc("damaged", player, damage, throw_origin.x)
	return true

# Override this function to do a special effect
# when colliding with a platform
# warning-ignore:unused_argument
func env_effect(platform) -> bool:
	return true

func disable() -> void:
	sprite.visible = false
	collision.set_deferred("disabled", true)
	_disabled = true

func enable() -> void:
	sprite.visible = true
	collision.set_deferred("disabled", false)
	_disabled = false

func _destroy():
	queue_free()

# Signal callbacks
func _on_body_entered(body: Node) -> void:
	var des: bool
	if body == player:
		return
	if body.is_in_group("player"):
		des = damage_enemy(body)
	elif body.is_in_group("platform"):
		des = env_effect(body)
	if des:
		_destroy()

func _on_cooldown_finished() -> void:
	print("Cooldown finished")
	_destroy()
