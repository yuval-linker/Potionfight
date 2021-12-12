extends Control

onready var center = $PotionWheelCenter

func _on_mouse_entered(potion_id: String) -> void:
	center.show_info(potion_id)

func _on_mouse_exited() -> void:
	center.hide_info()
