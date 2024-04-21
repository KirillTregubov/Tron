extends Node2D

@onready var menu = $Menu
var hosting: bool = false

func _ready() -> void:
	#get_tree().paused = true
	pass

func hide_menu() -> void:
	print('hide')
	#get_tree().paused = false
	visible = false
	menu.visible = false

func _on_host_button_pressed() -> void:
	print('hosting')
	#Lobby.create_game()
	hosting = true
	get_parent().peer.create_server(7000)
	get_parent().multiplayer.multiplayer_peer = get_parent().peer
	get_parent().multiplayer.peer_connected.connect(get_parent().spawn_player)

func _on_join_button_pressed() -> void:
	print('joining')
	#Lobby.join_game()
	#get_parent().load_game()
	
	get_parent().peer.create_client("localhost", 7000)
	get_parent().multiplayer.multiplayer_peer = get_parent().peer
	get_parent().load_game()

func _on_start_button_pressed() -> void:
	print('starting')
	#Lobby.load_game.rpc()
	#hide_menu()
	get_parent().load_game()
	if hosting:
		get_parent().spawn_player(1)
