extends Node2D

@onready var player_scene: PackedScene = preload("res://client/player/player.tscn")
@onready var players = $Players


func spawn_player(player_id: int) -> void:
	var player = player_scene.instantiate()
	player.set_name(str(player_id))
	players.call_deferred("add_child", player)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
