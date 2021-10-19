extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$TextureProgress.value = 100


func set_hp_value(val):
	$TextureProgress.value = val
