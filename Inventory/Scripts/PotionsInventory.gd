class_name PotionsInventoryResource
extends InventoryResource

signal potions_inventory_changed

func _init() -> void:
	inventory_type = "Potion"
	_max_size = 4

func set_items(new_items: Array) -> void:
	.set_items(new_items)
	emit_signal("potions_inventory_changed")

func set_max_size(new_size) -> void:
	.set_max_size(new_size)
	emit_signal("potions_inventory_changed")

func add_item(item_id: String, quantity: int) -> int:
	var remaining_q = .add_item(item_id, quantity)
	emit_signal("potions_inventory_changed")
	return remaining_q
