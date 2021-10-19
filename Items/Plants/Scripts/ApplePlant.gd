extends "res://Items/Plants/Scripts/Plant.gd"

func _ready() -> void:
	plant_id = "ApplePlant"
	if self.is_network_master():
		pick_up_quantity = 2
	._ready()
