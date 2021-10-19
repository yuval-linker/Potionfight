extends Node
# --------------------------------
# This script MUST be a Singleton!
# --------------------------------
# Implementation of a basic item database
# for easy access. 

var database = {}

# Initializes the database dictionary by reading a JSON and iterating over it.
func init_database():
	# Reads a JSON file with the paths and structure of the entity db.
	var file = File.new()
	file.open("res://Managers/entity.json", file.READ)
	var entities = JSON.parse(file.get_as_text()).result
	file.close()
	
	# Iterates over all entity types.
	for entity_type in entities.keys():
		var type_data = entities[entity_type]
		var typed_entities = {}
		for id in type_data["Identifier"]:
			var entry = {"Identifier": id}
			var paths = type_data["Path"]
			for key in paths.keys():
				var path = paths[key][0]
				var file_type = paths[key][1]
				entry[key] = load(path + ("/%s" % id) + file_type)
			typed_entities[id] = entry
		database[entity_type] = typed_entities

# Public method, gets an entity from the db.
func get_entity(entity_type: String, entity_id: String) -> Dictionary:
	var typed_entities = database[entity_type]
	if not typed_entities.has(entity_id):
		return {}
	else:
		return typed_entities[entity_id]

func _ready() -> void:
	init_database()
