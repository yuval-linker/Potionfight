extends Control

onready var connect = $Connect
onready var playersPanel = $Players
onready var errorLabel = $Connect/ErrorLabel
onready var host = $Connect/HostButton
onready var join = $Connect/JoinButton
onready var nameText = $Connect/Name
onready var errorDialog = $ErrorDialog
onready var playerList = $Players/List


func _ready() -> void:
	Gamestate.connect("connection_failed", self, "_on_connection_failed")
	Gamestate.connect("connection_succeeded", self, "_on_connection_success")
	Gamestate.connect("player_list_changed", self, "refresh_lobby")
	Gamestate.connect("game_ended", self, "_on_game_ended")
	Gamestate.connect("game_error", self, "_on_game_error")
	
	host.connect("pressed", self, "_on_host_pressed")
	join.connect("pressed", self, "_on_join_pressed")
	$Players/StartButton.connect("pressed", self, "_on_start_pressed")
	$Players/LinkButton.connect("pressed", self, "_on_find_public_ip_pressed")
	
	if OS.has_environment("USERNAME"):
		nameText.text = OS.get_environment("USERNAME")
	else:
		var desktop_path = OS.get_system_dir(0).replace("\\", "/").split("/")
		nameText.text = desktop_path[desktop_path.size() - 2]

func _on_host_pressed():
	var candidate_name = nameText.text.strip_edges()
	if  candidate_name == "":
		errorLabel.text = "Invalid name!"
		return
	
	connect.hide()
	playersPanel.show()
	errorLabel.text = ""
	
	var player_name = candidate_name
	Gamestate.host_game(player_name)
	refresh_lobby()

func _on_join_pressed():
	var candidate_name = nameText.text.strip_edges()
	if  candidate_name == "":
		errorLabel.text = "Invalid name!"
		return
	
	var ip = $Connect/IPAddress.text
	if not ip.is_valid_ip_address():
		errorLabel.text = "Invalid IP address"
		return
	
	errorLabel.text = ""
	host.disabled = true
	join.disabled = true
	
	var player_name = candidate_name
	Gamestate.join_game(ip, player_name)

func _on_connection_success():
	connect.hide()
	playersPanel.show()

func _on_connection_failed():
	host.disabled = false
	join.disabled = false
	errorLabel.set_text("Connection failed.")

func _on_game_ended():
	show()
	connect.show()
	playersPanel.hide()
	host.disabled = false
	join.disabled = false


func _on_game_error(errtxt):
	errorDialog.dialog_text = errtxt
	errorDialog.popup_centered_minsize()
	host.disabled = false
	join.disabled = false


func refresh_lobby():
	var players = Gamestate.get_player_list()
	players.sort()
	playerList.clear()
	playerList.add_item(Gamestate.get_player_name() + " (You)")
	for p in players:
		playerList.add_item(p)

	$Players/StartButton.disabled = not get_tree().is_network_server()


func _on_start_pressed():
	Gamestate.begin_game()


func _on_find_public_ip_pressed():
	OS.shell_open("https://icanhazip.com/")
