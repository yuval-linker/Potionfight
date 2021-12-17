extends Control

onready var playButton = $Button3/PlayButton
onready var controllerButton = $Button2/ControllerButton
onready var creditButton = $Button/CreditButton



func _ready() -> void:
	playButton.connect("pressed", self, "_on_play_pressed")
	controllerButton.connect("pressed", self, "_on_controller_pressed")
	creditButton.connect("pressed", self, "_on_credit_pressed")
	

func _on_play_pressed():
	get_tree().change_scene("res://UI/Scenes/Lobby.tscn")
	
	
func _on_controller_pressed():
	get_tree().change_scene("res://UI/Scenes/Controllers.tscn")


func _on_credit_pressed():
	get_tree().change_scene("res://UI/Scenes/Credits.tscn")
	



