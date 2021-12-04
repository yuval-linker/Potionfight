extends Area2D


func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")
	connect("area_entered", self, "_on_area_entered")

func _on_area_entered(area)->void:
	if area.is_in_group("potion"):
		area._destroy()

func _on_body_entered(body)->void:
	if body.is_in_group("player"):
		# Matar al player
		# Para debuggear se vuelve al player a spawn
		body.position = get_node("../../SpawnPoints/0").position
		pass
