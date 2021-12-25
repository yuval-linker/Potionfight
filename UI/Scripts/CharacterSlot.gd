class_name CharacterSlot
extends Control

# COMMON = 0, RARE = 1, EPIC = 2, LEGENDARY = 3 
const BORDERCOLOR = {
	0: Color("#FFFFFF"),
	1: Color("#0070DD"),
	2: Color("#9132C8"),
	3: Color("#FF8000"),
}

const EFFECTS = {
	"Burning": preload("res://UI/Assets/Buffs_Debuffs/burning.png"),
	"FireFist": preload("res://UI/Assets/Buffs_Debuffs/firefist.png"),
	"Intangible": preload("res://UI/Assets/Buffs_Debuffs/intangible.png"),
	"NoGravity": preload("res://UI/Assets/Buffs_Debuffs/no_gravity.png"),
	"Slow": preload("res://UI/Assets/Buffs_Debuffs/slow.png"),
	"Fast": preload("res://UI/Assets/Buffs_Debuffs/speedy.png"),
	"Stunned": preload("res://UI/Assets/Buffs_Debuffs/stun.png"),
	"PoweredPunch": preload("res://UI/Assets/Buffs_Debuffs/powered_punch.png")
}

const EffectScene = preload("res://UI/Scenes/Effect.tscn")
const CraftedPopup = preload("res://UI/Scenes/CraftedPopup.tscn")

const displayedEffects = {
	"Burning": null,
	"FireFist": null,
	"Intangible": null,
	"NoGravity": null,
	"Slow": null,
	"Fast": null,
	"Stunned": null,
	"PoweredPunch": null
}

onready var hpBar = $HpBar
onready var label = $Label
onready var lives = $Lives
onready var potionSprite = $EquippedPanel/Equipped/Control/PotionSprite
onready var potionLabel = $EquippedPanel/Label
onready var equippedPanel = $EquippedPanel
onready var craftedSpawn = $CraftedSpawn
onready var buffsAndDebuffs = $BuffsDebuffs

func set_name(name: String):
	if name.length() > 10:
		name = name.substr(0, 10) + "..."
	label.text = name

func set_hp_value(value: float):
	hpBar.value = value

func set_stock_lives(number: int):
	print("setting lives to", number)
	if number < lives.get_child_count() and number >= 0:
		for n in range(number, lives.get_child_count()):
			lives.get_child(n).queue_free()

func potion_popup(text: String)->void:
	var new_popup = CraftedPopup.instance()
	new_popup.position = craftedSpawn.position
	add_child(new_popup)
	new_popup.set_text(text)

func set_equipped_potion(potion_id: String)->void:
	var resource = EntityDatabase.get_entity("Potion", potion_id)["Resource"]
	potionSprite.texture = resource.image
	potionLabel.text = resource.name
	var color = BORDERCOLOR[resource.tier]
	equippedPanel["custom_styles/panel"].border_color = color

func add_effect(effect: String) -> void:
	if displayedEffects[effect] == null:
		var new_effect = EffectScene.instance()
		buffsAndDebuffs.add_child(new_effect)
		new_effect.set_image(EFFECTS[effect])
		displayedEffects[effect] = new_effect

func remove_effect(effect):
	if displayedEffects[effect] != null:
		var my_effect = displayedEffects[effect]
		my_effect.queue_free()
		displayedEffects[effect] = null

func clear_effects():
	for effect in buffsAndDebuffs.get_children():
		effect.queue_free()
