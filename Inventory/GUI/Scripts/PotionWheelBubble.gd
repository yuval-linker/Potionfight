extends Control

onready var bubble = $PotionQuantityBubble
onready var label = $PotionQuantity
onready var default_texture = load("res://Inventory/GUI/Assets/PotionWheel/potion_q_container.png")
onready var empty_texture = load("res://Inventory/GUI/Assets/PotionWheel/potion_q_container_empty.png")

func update_bubble(quantity: int) -> void:
	if quantity == 0:
		bubble.texture = empty_texture
	else:
		bubble.texture = default_texture
	label.text = str(quantity)
