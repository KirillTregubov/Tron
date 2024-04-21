extends Node2D


enum Status { LOBBY, GAME }
var status

var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
@onready var base_level_scene = preload("res://client/levels/base_level.tscn")

func scale_window():
	var window := get_window() as Window
	var retina_scale = DisplayServer.screen_get_scale()
	if (window.content_scale_factor != retina_scale):
		var relative_scale: float = retina_scale / window.content_scale_factor
		window.size = window.size * relative_scale
		window.move_to_center()

# Called when the node enters the scene tree for the first time.
func _ready():
	status = Status.LOBBY
	scale_window()
	#Lobby.player_connected.connect(func x(a, b): print(Lobby.players_loaded, ', a ', a, ' b ', b))
	#print('loaded ', multiplayer.get_unique_id())
	#Lobby.player_loaded.rpc_id(1) # multiplayer.get_remote_sender_id()
	#Lobby.create_game()
	
	print('ready')

func load_game():
	print('loaded game')
	$TitleMenu.hide_menu()
	add_child(base_level_scene.instantiate())
	status = Status.GAME

# Called only on the server.
func start_game():
	# All peers are ready to receive RPCs in this scene.
	print('starting game on server')
	
	#print(Lobby.players)

func spawn_player(player_id: int):
	if (status == Status.GAME):
		print('spawn player')
		$BaseLevel.spawn_player(player_id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	pass
