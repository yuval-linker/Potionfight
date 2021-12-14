extends Control

onready var backButton = $Button/BackButton
onready var camera = $Camera2D

func _ready() -> void:
	backButton.connect("pressed", self, "_on_back_pressed")
	camera.current = true

func _on_back_pressed():
	get_tree().change_scene("res://UI/Scenes/Lobby.tscn")
	Gamestate.end_game()
