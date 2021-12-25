extends Node2D

const INDEX_CAP: int = 1028
export(int) var LOWER_TIME_RANGE = 5
export(int) var UPPER_TIME_RANGE = 20

enum ItemTier {COMMON, RARE, EPIC, LEGENDARY}

var identifiers = {
	"COMMON": [], # 50%
	"RARE": [], # 25%
	"EPIC": [], # 15%
	"LEGENDARY": [] # 10%
}

onready var leftBoundary = $Left
onready var rightBoundary = $Right
var spawnTimer: Timer
var plant_index: int = 0

func _ready() -> void:
	if get_tree().is_network_server():
		poblate_identifiers()
		randomize()
		spawnTimer = Timer.new()
		add_child(spawnTimer)
		var _ret = spawnTimer.connect("timeout", self, "_on_spawn_timeout")
		var time = LOWER_TIME_RANGE + randi() % UPPER_TIME_RANGE
		spawnTimer.one_shot = true
		spawnTimer.start(time)

func poblate_identifiers():
	var plants = EntityDatabase.database["Plant"]
	for p in plants:
		var tier: String = ItemTier.keys()[EntityDatabase.get_entity("Plant", p)["Resource"].tier]
		identifiers[tier].append(p)

func get_random_plant()->String:
	var index: int = randi() % 100
	var tier: String
	if index < 50:
		tier = "COMMON"
	elif index < 75:
		tier = "RARE"
	elif index < 90:
		tier = "EPIC"
	else:
		tier = "LEGENDARY"
	var arr: Array = identifiers[tier]
	var new_index: int = randi() % arr.size()
	return arr[new_index]

remotesync func spawn_plant(plant: String, pos: Vector2)->void:
	var new_plant = EntityDatabase.get_entity("Plant", plant)["Scene"].instance()
	new_plant.global_position = pos
	new_plant.set_name(new_plant.get_name() + str(plant_index))
	add_child(new_plant)
	plant_index += 1
	plant_index = plant_index % INDEX_CAP

func _on_spawn_timeout()->void:
	var pos = Vector2(rand_range(leftBoundary.position.x, rightBoundary.position.x), leftBoundary.position.y)
	var plant = get_random_plant()
	rpc("spawn_plant", plant, pos)
	var time = LOWER_TIME_RANGE + randi() % UPPER_TIME_RANGE
	spawnTimer.start(time)
