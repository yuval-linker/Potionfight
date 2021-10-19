extends "res://Items/Plants/Scripts/Plant.gd"

func _ready() -> void:
	plant_id = "LightPlant"
	if self.is_network_master():
		pick_up_quantity = 1
	._ready()
