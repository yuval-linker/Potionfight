extends Control

onready var backButton = $Button/BackButton
onready var potionButton = $Button2/PotionButton


func _ready() -> void:
	backButton.connect("pressed", self, "_on_back_pressed")
	potionButton.connect("pressed", self, "_on_potion_pressed")

func _on_back_pressed():
	get_tree().change_scene("res://UI/Scenes/Main.tscn")
	
func _on_potion_pressed():
	get_tree().change_scene("res://UI/Scenes/PotionMenu.tscn")
