extends Node2D

func _on_host_button_pressed() -> void:
	print('hosting')
	Lobby.create_game()

func _on_join_button_pressed() -> void:
	print('joining')
	Lobby.join_game()

func _on_start_button_pressed() -> void:
	print('starting')
	Lobby.load_game. rpc ("res://client/main/main.tscn")
