extends Control

onready var potion_name_label = $PotionName
onready var recipe_container = $RecipeContainer

const input_scene = preload("res://Inventory/GUI/Scenes/RecipeInput.tscn")

func show_info(potion_id: String) -> void:
	var potion_entity = EntityDatabase.get_entity("Potion", potion_id)
	var potion_name = potion_entity["Resource"].name
	potion_name_label.text = potion_name + "'s \nrecipe:"

	var recipe = potion_entity["Recipe"]
	var n = len(recipe.input_ids)
	assert(n == len(recipe.input_quantities))
	for i in range(n):
		var input = input_scene.instance()
		input.init_recipe_input(recipe.input_ids[i], recipe.input_quantities[i])
		recipe_container.add_child(input)

func hide_info() -> void:
	potion_name_label.text = ""
	for input in recipe_container.get_children():
		recipe_container.remove_child(input)
		input.queue_free()
