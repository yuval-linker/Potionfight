extends Node

const DEFAULT_PORT = 10567 # We can change it
const MAX_PEERS = 2 # Only 1v1

# Network peer
var peer: NetworkedMultiplayerENet = null

# Name for player
var player_name = "This Player"

# its a dictionary rather than a single parameter for
# future multiplayer modes other than 1v1
# format id->name
var players = {}
var players_ready = []
var player_nodes = {}

# signals for lobby GUI
signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)

# Callbacks from SceneTree

func _player_connected(id):
	rpc_id(id, "register_player", player_name)

func _player_disconnected(id):
	if has_node("/root/Level"): # Game is in progress
		if get_tree().is_network_server():
			emit_signal("game_error", "Player " + players[id] + " disconnected")
			end_game()
	else: # Game has not started yet
		unregister_player(id)

func _connected_ok():
	emit_signal("connection_succeeded")

func _server_disconnected():
	emit_signal("game_error", "Server disconnected")
	end_game()

func _connected_fail():
	get_tree().set_network_peer(null)
	emit_signal("connection_failed")

# Lobby management functions

# remote to sync lobbies player lists
remote func register_player(new_player_name):
	var id = get_tree().get_rpc_sender_id()
	players[id] = new_player_name
	emit_signal("player_list_changed")

func unregister_player(id):
	players.erase(id)
	emit_signal("player_list_changed")

remote func pre_start_game(spawn_points):
	# Change Scene to level
	var level = load("res://World/Stages/ExampleStage/Scenes/Level.tscn").instance()
	get_tree().get_root().add_child(level)
	# Hide Lobby
	get_tree().get_root().get_node("Lobby").hide()
	
	# Player Scene
	var player_scene = load("res://Player/Scenes/Player.tscn")
	var gui_slot_scene = load("res://UI/Scenes/CharacterSlot.tscn")
	
	for p_id in spawn_points:
		var spawn_pos = level.get_node("SpawnPoints/" + str(spawn_points[p_id])).position
		var player = player_scene.instance()
		
		player.set_name(str(p_id))
		player.position = spawn_pos
		player.set_network_master(p_id)
		
		if p_id == get_tree().get_network_unique_id():
			player.set_player_name(player_name)
		else:
			player.set_player_name(players[p_id])
			
		player_nodes[p_id] = player
		var gui_slot = gui_slot_scene.instance()
		level.get_node("GUI/Slots").add_child(gui_slot)
		player.set_gui_slot(gui_slot)
		level.get_node("Players").add_child(player)
	
	var inventory = level.get_node("GUI/Inventory")
	inventory.set_player(player_nodes[get_tree().get_network_unique_id()])
	
	var potion_wheel = level.get_node("GUI/PotionWheel")
	potion_wheel.set_player(player_nodes[get_tree().get_network_unique_id()])
	
	# Tell server we are ready to start
	if not get_tree().is_network_server():
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	elif players.size() == 0: # If you are playing alone
		post_start_game()

remote func post_start_game():
	get_tree().set_pause(false)
	players_ready.clear()

remote func ready_to_start(id):
	assert(get_tree().is_network_server())
	
	if not id in players_ready:
		players_ready.append(id)
	
	if players_ready.size() == players.size():
		for p in players:
			rpc_id(p, "post_start_game")
		post_start_game()

func host_game(new_player_name):
	player_name = new_player_name
	peer = NetworkedMultiplayerENet.new()
	var _error = peer.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().set_network_peer(peer)

func join_game(ip, new_player_name):
	player_name = new_player_name
	peer = NetworkedMultiplayerENet.new()
	var _error = peer.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(peer)

func get_player_list():
	return players.values()

func get_player_name():
	return player_name

func begin_game():
	assert(get_tree().is_network_server())
	
	var spawn_points = {}
	spawn_points[1] = 0
	var spawn_point_idx = 1
	for p in players:
		spawn_points[p] = spawn_point_idx
		spawn_point_idx += 1
	
	# Pre start game for all players
	for p in players:
		rpc_id(p, "pre_start_game", spawn_points)
	
	pre_start_game(spawn_points)

func end_screen():
	get_node("/root/Level/Camera2D").current = false
	for child in get_node("/root/Level/GUI").get_children():
		child.hide()
	if not player_nodes[get_tree().get_network_unique_id()].dead:
		# show victory screen
		var _err = get_tree().change_scene("res://UI/Scenes/VictoryScreen.tscn")
	else:
		# show defeat screen
		var _err = get_tree().change_scene("res://UI/Scenes/DefeatScreen.tscn")
	get_tree().set_pause(true)
	if get_tree().is_network_server():
		close_server()
	else:
		get_tree().set_network_peer(null)
#	peer.close_connection()

func close_server():
	for player in players:
		if player != 1:
			peer.disconnect_peer(player)
	
	peer.close_connection()
	get_tree().set_network_peer(null)
	print("SERVER CLOSED")

func end_game():
	if has_node("/root/Level"):
		get_node("/root/Level").queue_free()
	
	emit_signal("game_ended")
	players.clear()
	player_nodes.clear()


func _ready() -> void:
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_player_connected")
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "_connected_ok")
# warning-ignore:return_value_discarded
	get_tree().connect("connection_failed", self, "_connected_fail")
# warning-ignore:return_value_discarded
	get_tree().connect("server_disconnected", self, "_server_disconnected")
