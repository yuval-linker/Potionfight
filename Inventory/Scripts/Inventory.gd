class_name InventoryResource
extends Resource
# This class holds de common behaviour of a player inventory.

var _items = Array() setget set_items, get_items
var _max_size setget set_max_size, get_max_size
var inventory_type

func set_items(new_items: Array) -> void:
	_items = new_items

func get_items() -> Array:
	return _items
	
func set_max_size(new_size) -> void:
	_max_size = new_size

func get_max_size() -> int:
	return _max_size
	
func get_item(index : int) -> ItemResource:
	return _items[index]
		
func add_item(item_id: String, quantity: int) -> int:
	if quantity == 0:
		print("WARNING (add_item): quantity = 0, nothing done.")
		return 0 
	var item = EntityDatabase.get_entity(inventory_type, item_id)
	
	if not item:
		print("ERROR (add_item): Item isn't at the Database.")
		return 0
	
	var remaining_q = quantity
	var max_stack_q = item["Resource"].max_stack_size if item["Resource"].stackable else 1
	
	if item["Resource"].stackable:
		for i in range(_items.size()):
			if remaining_q == 0:
				break
			var inventory_item = _items[i]
			if inventory_item.item_reference["Identifier"] != item["Identifier"]:
				continue
			if inventory_item.quantity < max_stack_q:
				var og_quantity = inventory_item.quantity
				inventory_item.quantity = min(og_quantity + remaining_q, max_stack_q)
				remaining_q -= (inventory_item.quantity - og_quantity)

	while remaining_q > 0 and _items.size() < _max_size:
		var new_item = {
			"item_reference": item,
			"quantity": min(remaining_q, max_stack_q)
		}
		remaining_q -= new_item.quantity
		_items.append(new_item)

	return remaining_q

func get_item_quantity(item_id: String) -> int:
	var total_q = 0
	for item in _items:
		if item.item_reference["Identifier"] == item_id:
			total_q += item.quantity
	return total_q

func consume_item(item_id: String, quantity: int) -> int:
	# Looping backwards over the items array
	var remaining_q = quantity
	var i = _items.size() - 1
	while (i >= 0 and remaining_q > 0):
		var inv_item = _items[i]
		if inv_item.item_reference["Identifier"] == item_id:
			var new_inv_q = inv_item.quantity - remaining_q
			if new_inv_q <= 0:
				_items.remove(i)
				remaining_q = -new_inv_q
			else:
				_items[i].quantity = new_inv_q
				remaining_q = 0
		i -= 1
	return remaining_q
