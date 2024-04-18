extends Node2D

func scale_window():
	var window := get_window() as Window
	var retina_scale = DisplayServer.screen_get_scale()
	if (window.content_scale_factor != retina_scale):
		var relative_scale: float = retina_scale / window.content_scale_factor
		window.size = window.size * relative_scale
		window.move_to_center()

# Called when the node enters the scene tree for the first time.
func _ready():
	scale_window()
	#Lobby.player_connected.connect(func x(a, b): print(Lobby.players_loaded, ', a ', a, ' b ', b))
	Lobby.player_loaded.rpc_id(1) # multiplayer.get_remote_sender_id()
	#Lobby.create_game()

# Called only on the server.
func start_game():
	# All peers are ready to receive RPCs in this scene.
	print('starting game on server')
	print(Lobby.players)

# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	pass
