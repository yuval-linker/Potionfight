extends TextureButton

onready var default_texture = load("res://Inventory/GUI/Assets/PotionWheel/slot_3.png")
onready var default_texture_hover = load("res://Inventory/GUI/Assets/PotionWheel/slot_3_hover.png")
onready var empty_texture = load("res://Inventory/GUI/Assets/PotionWheel/slot_3_empty.png")
onready var empty_texture_hover = load("res://Inventory/GUI/Assets/PotionWheel/slot_3_empty_hover.png")

func update_slot(potions_inventory: PotionsInventoryResource) -> void:
	var quantity = potions_inventory.get_item_quantity("FirePotion")
	if quantity > 0:
		self.texture_normal = default_texture
		self.texture_hover = default_texture_hover
	else:
		self.texture_normal = empty_texture
		self.texture_hover = empty_texture_hover
	$Bubble.update_bubble(quantity)
	
