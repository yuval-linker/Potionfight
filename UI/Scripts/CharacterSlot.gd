class_name CharacterSlot
extends Control

onready var hpBar = $HpBar
onready var label = $Label
onready var lives = $Lives

func set_name(name: String):
	label.text = name

func set_hp_value(value: float):
	hpBar.value = value

func set_stock_lives(number: int):
	print("setting lives to", number)
	if number < lives.get_child_count() and number >= 0:
		for n in range(number, lives.get_child_count()):
			lives.get_child(n).queue_free()
