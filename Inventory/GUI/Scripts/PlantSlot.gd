extends TextureRect

onready var label:Label = $Label
onready var imageRect:TextureRect = $PlantImage

func _ready() -> void:
	_hide()

func _hide() -> void:
	imageRect.hide()
	label.hide()

func _show() -> void:
	imageRect.show()
	label.show()

func empty() -> void:
	_hide()
	
func add_plant(plant: Dictionary) -> void:
	var item: Resource = plant["item_reference"]["Resource"]
	var quantity: int = plant["quantity"]
	imageRect.texture = item.image
	label.text = str(quantity)
	_show()
