extends Control

onready var imageRect = $TextureRect

func set_image(image: Texture) -> void:
	imageRect.texture = image
