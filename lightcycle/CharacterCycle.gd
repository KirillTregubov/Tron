extends CharacterBody2D

enum State {idle, moving}

var player: Constants.Player
var move_state = State.idle
var move_direction: Constants.Direction
var old_move_direction
var move_amount: int
const TRAIL_DIMENSION = 4
const SPEED = 250.0
@onready var sprite = $Sprite2D as Sprite2D
@onready var trails = $"../Trails" as Node2D
var trail = preload ("res://trail/trail.tscn")

const MIN_MOVE_AMOUNT = 3
const MAX_TICK_DURATION = 200 # 200ms
var move_queue = []


func _process(_delta):
	var current_tick = Time.get_ticks_msec()

	for i in range(move_queue.size() - 1, -1, -1):
		if current_tick - move_queue[i].tick < MAX_TICK_DURATION:
			return
		else:
			move_queue.remove_at(i)


func _input(event: InputEvent) -> void:
	var tick = Time.get_ticks_msec()
	if event.is_action_pressed("ui_up") and move_direction != Constants.Direction.up:
		move_queue.append({"direction": Constants.Direction.up, "tick": tick})
	elif event.is_action_pressed("ui_down") and move_direction != Constants.Direction.down:
		move_queue.append({"direction": Constants.Direction.down, "tick": tick})
	elif event.is_action_pressed("ui_left") and move_direction != Constants.Direction.left:
		move_queue.append({"direction": Constants.Direction.left, "tick": tick})
	elif event.is_action_pressed("ui_right") and move_direction != Constants.Direction.right:
		move_queue.append({"direction": Constants.Direction.right, "tick": tick})


func calculate_direction() -> Constants.Direction:
	# NOTE: consider handling emergency turns to avoid death?
	#var up = Input.is_action_pressed("ui_up")
	#var down = Input.is_action_pressed("ui_down")
	#var left = Input.is_action_pressed("ui_left")
	#var right = Input.is_action_pressed("ui_right")
	
	var opposite: Constants.Direction
	match move_direction:
		Constants.Direction.up:
			opposite = Constants.Direction.down
		Constants.Direction.down:
			opposite = Constants.Direction.up
		Constants.Direction.left:
			opposite = Constants.Direction.right
		Constants.Direction.right:
			opposite = Constants.Direction.left
		_:
			printerr("Invalid move_direction in calculate_direction()")
			get_tree().quit()
			return move_direction
	
	var current_move = move_queue.filter(func(x): return x.direction != opposite and (old_move_direction == null or (old_move_direction != x.direction and move_amount > 1) or move_amount > MIN_MOVE_AMOUNT)).pop_front()
	if current_move == null:
		return move_direction
	move_queue.pop_at(move_queue.find(current_move.direction))
	return current_move.direction


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
			printerr("Invalid direction in directional_velocity()")
			get_tree().quit()
			return Vector2(0, 0)


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
			printerr("Invalid direction in directional_rotation()")
			get_tree().quit()
			return 0


func directional_position(direction: Constants.Direction) -> Vector2:
	var cur_pos: Vector2 = self.position
	var middle = (sprite.get_rect().size.y - sprite.get_rect().size.x) / 2
	middle += 2
	#var change = TRAIL_DIMENSION - middle
	match direction:
		Constants.Direction.up:
			cur_pos.y -= middle
		Constants.Direction.down:
			cur_pos.y += middle
		Constants.Direction.left:
			cur_pos.x -= middle
		Constants.Direction.right:
			# adjust for thick trail
			#if move_direction == Constants.Direction.up:
				#cur_pos.y -= change
			#else:
				#cur_pos.y += change
			
			# align to old top
			#cur_pos.y -= sprite.get_rect().size.y / 2 - sprite.get_rect().size.x / 2
			# align to old bottom
			#cur_pos.y += (sprite.get_rect().size.y - sprite.get_rect().size.x)/ 2
			cur_pos.x += middle
		_:
			printerr("Invalid direction in directional_position()")
			get_tree().quit()
	return cur_pos


func spawn_trail(change: Vector2, padding = Vector2(0, 0)):
	# Calculate scale
	var scaleVec: Vector2 = change.abs() / Vector2(TRAIL_DIMENSION, TRAIL_DIMENSION)
	scaleVec.x = 1.0 if scaleVec.x == 0 else scaleVec.x
	scaleVec.y = 1.0 if scaleVec.y == 0 else scaleVec.y
	
	# Calculate offset
	var offset: Vector2
	match move_direction:
		Constants.Direction.up:
			offset = Vector2(0, TRAIL_DIMENSION)
		Constants.Direction.down:
			offset = Vector2(0, -TRAIL_DIMENSION)
		Constants.Direction.left:
			offset = Vector2(TRAIL_DIMENSION, 0)
		Constants.Direction.right:
			offset = Vector2(-TRAIL_DIMENSION, 0)
		_:
			offset = Vector2(0, 0)
	
	# Create trail
	var newTrail = trail.instantiate() as Node2D
	trails.add_child(newTrail)
	newTrail.set_global_position(global_position - change + offset + padding)
	if move_direction == Constants.Direction.left or move_direction == Constants.Direction.right:
		newTrail.set_scale(scaleVec.orthogonal())
		newTrail.set_rotation_degrees(90)
	else:
		newTrail.set_scale(scaleVec)


func crash() -> void:
	print('crashed')
	#get_tree().paused = true
	get_parent().queue_free()


func _ready() -> void:
	move_direction = get_parent().START_DIRECTION
	old_move_direction = null
	move_amount = 0
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
		var new_direction: Constants.Direction = direction
		var middle = (sprite.get_rect().size.y - sprite.get_rect().size.x) / 2
		if new_direction == Constants.Direction.left or new_direction == Constants.Direction.right:
			if move_direction == Constants.Direction.up:
				spawn_trail(Vector2(0, -middle), Vector2(0, -middle / 2))
				#spawn_trail(Vector2(0, -8), Vector2(0, -6))
			else:
				spawn_trail(Vector2(0, middle), Vector2(0, middle / 2))
		else:
			if move_direction == Constants.Direction.left:
				spawn_trail(Vector2(-middle, 0), Vector2(-middle / 2, 0))
			else:
				spawn_trail(Vector2(middle, 0), Vector2(middle / 2, 0))
			
		set_velocity(directional_velocity(new_direction))
		set_rotation_degrees(directional_rotation(new_direction))
		set_position(directional_position(new_direction))
		
		old_move_direction = move_direction
		move_direction = new_direction
		move_amount = 0
		return
	
	# Add Trail
	spawn_trail(delta * velocity)
	
	# Move and snap position
	var collision = move_and_collide(delta * velocity)
	move_amount += 1
	if collision and collision.has_method('get_collider'):
		print(collision.get_collider())
		if (collision.get_collider()):
			print('foreign')
			crash()
	global_position = Vector2(round(global_position.x), round(global_position.y))
