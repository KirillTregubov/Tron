extends CharacterBody2D

enum State {idle, moving}

var move_state = State.idle
var move_direction: Constants.Direction
const TRAIL_DIMENSION = 8
const SPEED = 250.0
@onready var player = $Sprite2D as Sprite2D
@onready var trails = $"../Trails"
var trail = preload("res://trail/trail.tscn")


func calculate_direction() -> Constants.Direction:
	var up = Input.is_action_pressed("ui_up")
	var down = Input.is_action_pressed("ui_down")
	var left = Input.is_action_pressed("ui_left")
	var right = Input.is_action_pressed("ui_right")
	
	if up and move_direction != Constants.Direction.down:
		if not down: return Constants.Direction.up
	if down and move_direction != Constants.Direction.up:
		if not up: return Constants.Direction.down
	if left and move_direction != Constants.Direction.right:
		if not right: return Constants.Direction.left
	if right and move_direction != Constants.Direction.left:
		if not left: return Constants.Direction.right
	
	return move_direction


func directional_velocity(direction: Constants.Direction) -> Vector2:
	match direction:
		Constants.Direction.up:
			return Vector2(0, -SPEED)
		Constants.Direction.down:
			return Vector2(0, SPEED)
		Constants.Direction.left:
			return Vector2(-SPEED, 0)
		Constants.Direction.right:
			return Vector2(SPEED, 0)
		_:
			printerr("Invalid direction")
			get_tree().quit()
			return Vector2(0,0)


func directional_rotation(direction: Constants.Direction) -> float:
	match direction:
		Constants.Direction.up:
			return 0
		Constants.Direction.down:
			return 180
		Constants.Direction.left:
			return 270
		Constants.Direction.right:
			return 90
		_:
			printerr("Invalid direction")
			get_tree().quit()
			return 0


func directional_position(direction: Constants.Direction) -> Vector2:
	var cur_pos: Vector2 = self.position
	match direction:
		Constants.Direction.up:
			cur_pos.y -= (player.get_rect().size.y - player.get_rect().size.x)/ 2
		Constants.Direction.down:
			cur_pos.y += (player.get_rect().size.y - player.get_rect().size.x)/ 2
		Constants.Direction.left:
			cur_pos.x -= (player.get_rect().size.y - player.get_rect().size.x)/ 2
		Constants.Direction.right:
			# align to old top
			#cur_pos.y -= player.get_rect().size.y / 2 - player.get_rect().size.x / 2
			# align to old bottom
			#cur_pos.y += (player.get_rect().size.y - player.get_rect().size.x)/ 2
			cur_pos.x += (player.get_rect().size.y - player.get_rect().size.x)/ 2
		_:
			printerr("Invalid direction")
			get_tree().quit()
	return cur_pos


func spawn_trail(change: Vector2, padding = Vector2(0, 0), rotate = false):
	# Calculate scale
	var scaleVec = change.abs() / Vector2(TRAIL_DIMENSION, TRAIL_DIMENSION)
	scaleVec.x = 1 if scaleVec.x == 0 else scaleVec.x
	scaleVec.y = 1 if scaleVec.y == 0 else scaleVec.y
	
	# Calculate offset
	var offset: Vector2
	match move_direction:
		Constants.Direction.up:
			offset = Vector2(0, TRAIL_DIMENSION/2)
		Constants.Direction.down:
			offset = Vector2(0, -TRAIL_DIMENSION/2)
		Constants.Direction.left:
			offset = Vector2(TRAIL_DIMENSION/2, 0)
		Constants.Direction.right:
			offset = Vector2(-TRAIL_DIMENSION/2, 0)
		_:
			offset = Vector2(0,0)
	
	# Create trail
	var newTrail = trail.instantiate() as Node2D
	trails.add_child(newTrail)
	newTrail.set_global_position(global_position - change + offset + padding)
	newTrail.set_scale(scaleVec)
	if rotate:
		newTrail.set_rotation_degrees(90)
	#get_tree().paused = true


func _ready() -> void:
	move_direction = get_parent().START_DIRECTION
	position.x = get_parent().START_POSITION_X
	position.y = get_parent().START_POSITION_Y
	set_rotation_degrees(directional_rotation(move_direction))
	if move_state == State.moving:
		set_velocity(directional_velocity(move_direction))


func _physics_process(delta: float) -> void:
	# Temporarily start moving
	if move_state != State.moving:
		if Input.is_action_just_pressed("ui_accept"):
			move_state = State.moving
			set_velocity(directional_velocity(move_direction))
			set_rotation_degrees(directional_rotation(move_direction))
		return
	elif Input.is_action_just_pressed("ui_accept"):
		move_state = State.idle
		return
	
	# Change direction
	var direction = calculate_direction()
	if direction != move_direction and direction is int:
		var new_direction : Constants.Direction = direction
		if new_direction == Constants.Direction.left or new_direction == Constants.Direction.right:
			if move_direction == Constants.Direction.up:
				spawn_trail(Vector2(0, -6), Vector2(0, -3))
			else:
				spawn_trail(Vector2(0, 6), Vector2(0, 3))
		else:
			if move_direction == Constants.Direction.left:
				spawn_trail(Vector2(0, -6), Vector2(3, -6), true)
			else:
				spawn_trail(Vector2(0, -6), Vector2(-3, -6), true)
		set_velocity(directional_velocity(new_direction))
		set_rotation_degrees(directional_rotation(new_direction))
		set_position(directional_position(new_direction))
		move_direction = new_direction
		return
	
	# Add Trail
	spawn_trail(delta * velocity)
	
	# Move and snap position
	move_and_slide()
	global_position = Vector2(round(global_position.x), round(global_position.y))
