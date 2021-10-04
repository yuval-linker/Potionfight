extends Camera2D

var center_point: Vector2 = Vector2.ZERO
var zoom_vec: Vector2 = Vector2(0.5, 0.5)

export(float, 0.0, 1.0) var MAX_ZOOM = 0.2
export(float, 0.0, 1.0) var MIN_ZOOM = 0.5
export var ZOOM_LIMITER = 600.0

func _ready() -> void:
	# So that its the last thing to be processed
	set_process_priority(1000)

func _process(delta: float) -> void:
	var new_pos = Vector2.ZERO
	var bounds: Rect2
	for p in Gamestate.player_nodes.values():
		new_pos += p.global_position
		if !bounds:
			bounds = Rect2(p.global_position, Vector2.ZERO)
		else:
			bounds = bounds.expand(p.global_position)
	
	new_pos = new_pos / Gamestate.player_nodes.size()
	
	position = new_pos
	var new_zoom = lerp(MAX_ZOOM, MIN_ZOOM, min(max(bounds.size.x, bounds.size.y) / ZOOM_LIMITER, 1))
	zoom = Vector2(new_zoom, new_zoom)
