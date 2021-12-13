extends Boundary

var down_rect

func _ready() -> void:
	down_rect = $CollisionShape2D.shape.extents.x
	y_offset = $CollisionShape2D.position.y - down_rect
	rotation_radians = deg2rad(270)
	anim_offset = Vector2(35, 0)
