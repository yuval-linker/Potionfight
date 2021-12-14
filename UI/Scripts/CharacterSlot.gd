class_name CharacterSlot
extends Control

# COMMON = 0, RARE = 1, EPIC = 2, LEGENDARY = 3 
const BORDERCOLOR = {
	0: Color("#FFFFFF"),
	1: Color("#0070DD"),
	2: Color("#9132C8"),
	3: Color("#FF8000"),
}


onready var hpBar = $HpBar
onready var label = $Label
onready var lives = $Lives
onready var potionSprite = $EquippedPanel/Equipped/Control/PotionSprite
onready var potionLabel = $EquippedPanel/Label
onready var equippedPanel = $EquippedPanel

func set_name(name: String):
	if name.length() > 20:
		name = name.substr(0, 20) + "..."
	label.text = name

func set_hp_value(value: float):
	hpBar.value = value

func set_stock_lives(number: int):
	print("setting lives to", number)
	if number < lives.get_child_count() and number >= 0:
		for n in range(number, lives.get_child_count()):
			lives.get_child(n).queue_free()

func set_equipped_potion(potion_id: String)->void:
	var resource = EntityDatabase.get_entity("Potion", potion_id)["Resource"]
	potionSprite.texture = resource.image
	potionLabel.text = resource.name
	var color = BORDERCOLOR[resource.tier]
	equippedPanel["custom_styles/panel"].border_color = color
