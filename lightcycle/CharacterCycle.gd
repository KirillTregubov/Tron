extends CharacterBody2D

enum State {idle, moving}
enum Direction {up, down, left, right}

const SPEED = 250.0
const JUMP_VELOCITY = -400.0

var move_state = State.moving # State.idle
var move_direction = Direction.down
@onready var player = $Sprite2D as Sprite2D
@onready var trails = $"../Trails"
const TRAIL_DIMENSION = 8
var trail = preload("res://trail/trail.tscn")

var num = 0


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


func _ready() -> void:
	position.x = 640
	position.y = 200 #500 #
	if move_state == State.moving:
		set_velocity(directional_velocity(move_direction))
		set_rotation_degrees(directional_rotation(move_direction))


func calculate_direction():
	var up = Input.is_action_pressed("ui_up")
	var down = Input.is_action_pressed("ui_down")
	var left = Input.is_action_pressed("ui_left")
	var right = Input.is_action_pressed("ui_right")
	
	if up and move_direction != Direction.down:
		if down: return
		return Direction.up
	elif down and move_direction != Direction.up:
		if up: return
		return Direction.down
	elif left and move_direction != Direction.right:
		if right: return
		return Direction.left
	elif right and move_direction != Direction.left:
		if left: return
		return Direction.right
	
	return


func _physics_process(delta: float) -> void:
	if move_state != State.moving:
		return
	
	print('deltas ', delta, velocity, delta * velocity)
	print(global_position)
	
	if true:
		var change = delta * velocity
		print('change ', change, change.abs())
		var scaleVec = change.abs() / Vector2(TRAIL_DIMENSION, TRAIL_DIMENSION)
		scaleVec.x = 1 if scaleVec.x == 0 else scaleVec.x
		scaleVec.y = 1 if scaleVec.y == 0 else scaleVec.y
		print('scale vector ', scaleVec)
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
		num += 1
		#get_tree().paused = true
		
		#else:
			#newTrail.queue_free()
	#else:
		#get_tree().paused = true
		#pass
	
	var new_direction = calculate_direction()
	if new_direction != move_direction and new_direction is int:
		print('current', Direction.keys()[move_direction])
		print('new', Direction.keys()[new_direction])
		
		set_velocity(directional_velocity(new_direction))
		set_rotation_degrees(directional_rotation(new_direction))
		
		move_direction = new_direction
		get_tree().paused = true
	
	print('move')
	move_and_slide()
	print('end ', global_position)
