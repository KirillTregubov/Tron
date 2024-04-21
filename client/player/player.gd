extends CharacterBody2D
class_name Player

#var id: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _enter_tree() -> void:
	print('name: ', name, ' ', name.to_int())
	set_multiplayer_authority(name.to_int())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * 400
	
	move_and_slide()

#func set_id(player_id: int) -> void:
	#id = player_id
