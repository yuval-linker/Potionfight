extends VBoxContainer

onready var plantInv: HBoxContainer = $PlantInventory
onready var potionInv: HBoxContainer = $PotionsInventory
var playerPlantInv : PlantsInventoryResource
var player: Player

func set_player(new_player: Player):
	player = new_player
	playerPlantInv = player.plants_inventory
	playerPlantInv.connect("plants_inventory_changed", self, "on_plant_inv_change")

func on_plant_inv_change():
	var plants: Array = playerPlantInv.get_items()
	var plant_amount: int = plants.size()
	for i in playerPlantInv.get_max_size():
		var slot = plantInv.get_child(i)
		if i < plant_amount:
			slot.add_plant(plants[i])
		else:
			slot.empty()
func hide_inv_gui() -> void:
	self.hide()

func show_inv_gui() -> void:
	self.show()
