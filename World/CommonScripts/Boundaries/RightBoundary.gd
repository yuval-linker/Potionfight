extends Boundary


func _ready() -> void:
	var left_rect = $CollisionShape2D.shape.extents.x
	x_offset = $CollisionShape2D.position.x - left_rect
	rotation_radians = deg2rad(180)
	anim_offset = Vector2(38, 0)
