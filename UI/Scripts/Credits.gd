extends Control

onready var backButton = $Button/BackButton


func _ready() -> void:
	backButton.connect("pressed", self, "_on_back_pressed")

func _on_back_pressed():
	get_tree().change_scene("res://UI/Scenes/Main.tscn")
