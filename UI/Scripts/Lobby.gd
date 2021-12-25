extends Control

onready var connectPanel = $Connect
onready var playersPanel = $Players
onready var goBackButton = $Players/BackButton
onready var toMenuButton = $Connect/ToMenuNode/ToMenuButton
onready var errorLabel = $Connect/ErrorLabel
onready var buttonsNode = $Connect/ButtonsNode
onready var host = $Connect/ButtonsNode/HostNode/HostButton
onready var join = $Connect/ButtonsNode/JoinNode/JoinButton
onready var nameText = $Connect/NameNode/HBoxContainer/Name
onready var errorDialog = $ErrorDialog
onready var playerList = $Players/List
onready var ipNode = $Connect/IPNode
onready var ipAdress = $Connect/IPNode/IPAddress
onready var connectButton = $Connect/IPNode/ConnectNode/ConnectButton
onready var cancelButton = $Connect/IPNode/CancelNode/CancelButton
onready var popup = $Connect/ConnectingPopup
onready var popupAnim = $Connect/ConnectingPopup/AnimationPlayer

var candidate_name: String = ""

func _ready() -> void:
# warning-ignore:return_value_discarded
	Gamestate.connect("connection_failed", self, "_on_connection_failed")
# warning-ignore:return_value_discarded
	Gamestate.connect("connection_succeeded", self, "_on_connection_success")
# warning-ignore:return_value_discarded
	Gamestate.connect("player_list_changed", self, "refresh_lobby")
# warning-ignore:return_value_discarded
	Gamestate.connect("game_ended", self, "_on_game_ended")
# warning-ignore:return_value_discarded
	Gamestate.connect("game_error", self, "_on_game_error")
	
	host.connect("pressed", self, "_on_host_pressed")
	join.connect("pressed", self, "_on_join_pressed")
	connectButton.connect("pressed", self, "_on_connect_pressed")
	cancelButton.connect("pressed", self, "_on_cancel_pressed")
	goBackButton.connect("pressed", self, "_on_exit_lobby_pressed")
	toMenuButton.connect("pressed", self, "_on_go_back_to_menu")
# warning-ignore:return_value_discarded
	$Players/StartButton.connect("pressed", self, "_on_start_pressed")
# warning-ignore:return_value_discarded
	$Players/LinkButton.connect("pressed", self, "_on_find_public_ip_pressed")
	
	if OS.has_environment("USERNAME"):
		nameText.text = OS.get_environment("USERNAME")
	else:
		var desktop_path = OS.get_system_dir(0).replace("\\", "/").split("/")
		nameText.text = desktop_path[desktop_path.size() - 2]

func _on_host_pressed():
	candidate_name = nameText.text.strip_edges()
	if  candidate_name == "":
		errorLabel.text = "Invalid name!"
		return
	
	connectPanel.hide()
	playersPanel.show()
	errorLabel.text = ""
	
	var player_name = candidate_name
	Gamestate.host_game(player_name)
	refresh_lobby()

func _on_join_pressed():
	candidate_name = nameText.text.strip_edges()
	if  candidate_name == "":
		errorLabel.text = "Invalid name!"
		return
	
	errorLabel.text = ""
	connectButton.disabled = false
	cancelButton.disabled = false
	buttonsNode.hide()
	ipNode.show()

func _on_connect_pressed():
	var ip = ipAdress.text
	if not ip.is_valid_ip_address():
		errorLabel.text = "Invalid IP address"
		ipNode.hide()
		return
	
	errorLabel.text = ""
	connectButton.disabled = true
	cancelButton.disabled = true
	
	var player_name = candidate_name
	popup.popup_centered_ratio(0.5)
	popupAnim.play("joining")
	Gamestate.join_game(ip, player_name)

func _on_cancel_pressed():
	ipNode.hide()
	buttonsNode.show()
	

func _on_connection_success():
	popup.hide()
	popupAnim.stop()
	connectPanel.hide()
	playersPanel.show()

func _on_connection_failed():
	host.disabled = false
	join.disabled = false
	ipNode.hide()
	buttonsNode.show()
	popup.hide()
	popupAnim.stop()
	errorLabel.set_text("Connection failed.")

func _on_game_ended():
	show()
	connectPanel.show()
	playersPanel.hide()
	host.disabled = false
	join.disabled = false


func _on_game_error(errtxt):
	errorDialog.dialog_text = errtxt
	errorDialog.popup_centered_minsize()
	host.disabled = false
	join.disabled = false

func _on_exit_lobby_pressed():
	Gamestate.cancel_connection()
	playersPanel.hide()
	host.disabled = false
	join.disabled = false
	buttonsNode.show()
	ipNode.hide()
	connectPanel.show()

func _on_go_back_to_menu():
	get_tree().change_scene("res://UI/Scenes/Main.tscn")

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
# warning-ignore:return_value_discarded
	OS.shell_open("https://icanhazip.com/")
