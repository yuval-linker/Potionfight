extends Area2D

const GRAVITY = 500

var player: KinematicBody2D
var linear_vel: Vector2 = Vector2.ZERO
var _disabled: bool = false
var throw_origin: Vector2
export(int) var damage = 10

onready var cooldown: Timer = $CooldownTimer
onready var visibility_notify: VisibilityNotifier2D = $VisibilityNotifier2D
onready var sprite: Sprite = $Sprite
onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
# warning-ignore:return_value_discarded
	connect("body_entered", self, "_on_body_entered")
# warning-ignore:return_value_discarded
	cooldown.connect("timeout", self, "_on_cooldown_finished")
# warning-ignore:return_value_discarded
	visibility_notify.connect("screen_exited", self, "_on_screen_exited")

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
func damage_enemy(enemy) -> void:
	enemy.damaged(player, damage, throw_origin.x)

# Override this function to do a special effect
# when colliding with a platform
func env_effect(platform) -> void:
	return

func disable() -> void:
	sprite.visible = false
	collision.disabled = true
	_disabled = true

func enable() -> void:
	sprite.visible = true
	collision.disabled = false
	_disabled = false

func _destroy():
	queue_free()

# Signal callbacks
func _on_body_entered(body: Node) -> void:
	if body == player:
		return
	if body.is_in_group("player"):
		damage_enemy(body)
	elif body.is_in_group("platform"):
		env_effect(body)
	_destroy()

func _on_screen_exited() -> void:
	if not _disabled:
		_destroy()

func _on_cooldown_finished() -> void:
	_destroy()
