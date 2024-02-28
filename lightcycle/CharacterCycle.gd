extends CharacterBody2D

enum State {idle, moving}
enum Direction {up, down, left, right}

const SPEED = 250.0
const JUMP_VELOCITY = -400.0

var move_state = State.idle # State.idle
var move_direction = Direction.up
@onready var player = $Sprite2D as Sprite2D
@onready var trails = $"../Trails"
const TRAIL_DIMENSION = 8
const BIKE_WIDTH = 8
const BIKE_HEIGHT = 8
var trail = preload("res://trail/trail.tscn")

#var num = 0


func calculate_direction() -> Direction:
	var up = Input.is_action_pressed("ui_up")
	var down = Input.is_action_pressed("ui_down")
	var left = Input.is_action_pressed("ui_left")
	var right = Input.is_action_pressed("ui_right")
	
	if up and move_direction != Direction.down:
		if not down: return Direction.up
	if down and move_direction != Direction.up:
		if not up: return Direction.down
	if left and move_direction != Direction.right:
		if not right: return Direction.left
	if right and move_direction != Direction.left:
		if not left: return Direction.right
	
	return move_direction


func directional_velocity(direction: Direction) -> Vector2:
	match direction:
		Direction.up:
			return Vector2(0, -SPEED)
		Direction.down:
			return Vector2(0, SPEED)
		Direction.left:
			return Vector2(-SPEED, 0)
		Direction.right:
			return Vector2(SPEED, 0)
		_:
			printerr("Invalid direction")
			get_tree().quit()
			return Vector2(0,0)


func directional_rotation(direction: Direction) -> float:
	match direction:
		Direction.up:
			return 0
		Direction.down:
			return 180
		Direction.left:
			return 270
		Direction.right:
			return 90
		_:
			printerr("Invalid direction")
			get_tree().quit()
			return 0

func directional_position(direction: Direction) -> Vector2:
	var cur_pos: Vector2 = self.position
	var trail_offset = TRAIL_DIMENSION / 2
	match direction:
		Direction.up:
			cur_pos.y -= player.get_rect().size.x / 2
			pass
		Direction.down:
			cur_pos.y += player.get_rect().size.x / 2
			pass
		Direction.left:
			cur_pos.x -= player.get_rect().size.y / 2 - trail_offset
		Direction.right:
			cur_pos.x += player.get_rect().size.y / 2 - trail_offset
		_:
			printerr("Invalid direction")
			get_tree().quit()
	
	print('new pos ', cur_pos)
	return cur_pos
	#return Vector2(0,0)


func _ready() -> void:
	position.x = 640
	position.y = 500 #200 #
	set_rotation_degrees(directional_rotation(move_direction))
	if move_state == State.moving:
		set_velocity(directional_velocity(move_direction))


func _physics_process(delta: float) -> void:
	if move_state != State.moving:
		if Input.is_action_just_pressed("ui_accept"):
			move_state = State.moving
			set_velocity(directional_velocity(move_direction))
			set_rotation_degrees(directional_rotation(move_direction))
			print(rotation_degrees)
		return
	elif Input.is_action_just_pressed("ui_accept"):
		move_state = State.idle
		return
	
	print('deltas ', delta, velocity, delta * velocity)
	print('currently at ', global_position)
	
	# Change direction
	var direction = calculate_direction()
	#if (num > 0):
		#new_direction = Direction.right
		#get_tree().paused = true
		#move_and_slide()
		#return
	if direction != move_direction and direction is int:
		var new_direction : Direction = direction
		print('current ', Direction.keys()[move_direction])
		print('new ', Direction.keys()[new_direction])
		
		#set_velocity(directional_velocity(new_direction))
		#set_rotation_degrees(directional_rotation(new_direction))
		#set_position(directional_position(new_direction))
		
		#set_velocity(Vector2(0,0))
		
		#position.y += -2
		
		move_direction = new_direction
		#if move_direction == Direction.down:
		get_tree().paused = true
		return
	
	
	# Add Trail
	if true:
		var change = delta * velocity
		print('change ', change, change.abs())
		print('size', player.get_rect().size)
		var scaleVec = change.abs() / Vector2(TRAIL_DIMENSION, TRAIL_DIMENSION)
		scaleVec.x = 1 if scaleVec.x == 0 else scaleVec.x
		scaleVec.y = 1 if scaleVec.y == 0 else scaleVec.y
		#print('scale vector ', scaleVec)
		var newTrail = trail.instantiate() as Node2D
		trails.add_child(newTrail)
		
		#if (velocity.y == -SPEED):
		var offset: Vector2
		match move_direction:
			Direction.up:
				offset = Vector2(0, TRAIL_DIMENSION/2)
			Direction.down:
				offset = Vector2(0, -TRAIL_DIMENSION/2)
			Direction.left:
				offset = Vector2(TRAIL_DIMENSION/2, 0)
			Direction.right:
				offset = Vector2(-TRAIL_DIMENSION/2, 0)
			_:
				offset = Vector2(0,0)
		print('offset', offset)
		
		newTrail.set_global_position(global_position - change + offset) #+ Vector2(0, 20)
		newTrail.set_scale(scaleVec)
		print('spawned at ', newTrail.global_position, newTrail.scale)
		#newTrail.set_
		#get_tree().paused = true
		
		#else:
			#newTrail.queue_free()
	#else:
		#get_tree().paused = true
		#pass
	
	print('move')
	move_and_slide()
	global_position = Vector2(round(global_position.x), round(global_position.y))
	print('player at ', global_position)
	
	
	#get_tree().paused = true
	
