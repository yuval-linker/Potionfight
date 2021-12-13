extends Boundary


func _ready() -> void:
	var right_rect = $CollisionShape2D.shape.extents.x
	x_offset = $CollisionShape2D.position.x + right_rect
	anim_offset = Vector2(28, 0)
