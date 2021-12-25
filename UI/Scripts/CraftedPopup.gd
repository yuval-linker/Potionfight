extends Position2D

const SPEED = 30

onready var label = $Label
onready var tween = $Tween

func _ready() -> void:
	tween.interpolate_property(self, 'scale', scale, Vector2(1, 1), 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, 'scale', Vector2(1, 1), Vector2(0.1, 0.1), 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.4)
	tween.connect("tween_all_completed", self, "_on_scale_completed")
	tween.start()

func _physics_process(delta: float) -> void:
	position.y -= delta*SPEED

func _on_scale_completed()->void:
	self.queue_free()

func set_text(text: String) -> void:
	label.text = text
