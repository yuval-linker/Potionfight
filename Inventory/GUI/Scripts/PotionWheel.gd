extends Control

onready var center = $PotionWheelCenter
var playerPotionsInv : PotionsInventoryResource
var player: Player

func _on_mouse_entered(potion_id: String) -> void:
	center.show_info(potion_id)

func _on_mouse_exited() -> void:
	center.hide_info()

func set_player(new_player: Player):
	player = new_player
	playerPotionsInv = player.potions_inventory
	playerPotionsInv.connect("potions_inventory_changed", self, "_on_potions_inv_change")

func hide_inv_gui() -> void:
	center.hide_info()
	self.hide()

func show_inv_gui() -> void:
	self.show()
	
func _on_slot_clicked(potion_id: String) -> void:
	player.equip_potion(potion_id)
	player.hide_inv()

func _on_potions_inv_change() -> void:
	for slot in get_children():
		if slot.is_in_group("potionwheel_slot"):
			slot.update_slot(playerPotionsInv)
