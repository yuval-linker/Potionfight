extends Particles2D


func _ready() -> void:
	set_emitting(true)
	one_shot = true

func _physics_process(_delta: float) -> void:
	if not is_emitting():
		queue_free()
