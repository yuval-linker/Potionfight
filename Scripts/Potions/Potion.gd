extends Area2D

const GRAVITY = 500

var player: KinematicBody2D
var linear_vel = Vector2.ZERO
var _disabled = false

onready var cooldown: Timer = $CooldownTimer
onready var visibility_notify: VisibilityNotifier2D = $VisibilityNotifier2D
onready var sprite: Sprite = $Sprite
onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")
	cooldown.connect("timeout", self, "_on_cooldown_finished")
	visibility_notify.connect("screen_exited", self, "_on_screen_exited")

func _physics_process(delta: float) -> void:
	position += linear_vel * delta
	linear_vel.y += GRAVITY * delta

func throw(direction: Vector2) -> void:
	linear_vel = direction

func drink() -> void:
	disable()
	cooldown.start()

func disable() -> void:
	sprite.visible = false
	collision.disabled = true
	_disabled = true

func enable() -> void:
	sprite.visible = true
	collision.disabled = false
	_disabled = false

# Signal callbacks
func _on_body_entered(body: Node) -> void:
	if body != player:
		queue_free()

func _on_screen_exited() -> void:
	if not _disabled:
		queue_free()

func _on_cooldown_finished() -> void:
	queue_free()
