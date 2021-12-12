extends TextureRect

func init_recipe_input(plant_id: String, plant_q: int) -> void:
	self.texture = EntityDatabase.get_entity("Plant", plant_id)["Resource"].image
	$Quantity.text = str(plant_q)
