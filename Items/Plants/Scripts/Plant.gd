class_name Plant
extends Area2D

# Info about a plant, must be initialized 
# by the classes that inherit from Plant.
var plant_id
master var plant_owner
master var pick_up_quantity

# Child nodes
onready var collision_shape = $CollisionShape2D

func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")
	
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.is_network_master():
		# Telling the server to process the pick up.
		rpc_id(1, "process_pick_up", get_tree().get_network_unique_id())

puppet func delete_plant() -> void:
	self.queue_free()
	
master func process_pick_up(p_id: int) -> void:
	if plant_owner != null:
		return
	plant_owner = Gamestate.player_nodes[p_id]
	var params = {
		"node_name": self.name,
		"plant_id": plant_id,
		"quantity": pick_up_quantity
	}
	plant_owner.rpc_id(p_id, "pick_up_plant", params)

master func handle_pick_up(remaining_q: int) -> void:
	if remaining_q == 0:
		rpc("delete_plant")
		delete_plant()
	else:
		pick_up_quantity = remaining_q
		plant_owner = null
		
