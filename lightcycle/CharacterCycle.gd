extends CharacterBody2D

enum State {idle, moving}
enum Direction {up, down, left, right}

const SPEED = 250.0
const JUMP_VELOCITY = -400.0

var move_state = State.moving # State.idle
var move_direction = Direction.up
@onready var player = $Sprite2D
@onready var trails = $"../Trails"
const TRAIL_DIMENSION = 8
var trail = preload("res://trail/trail.tscn")

var num = 0


func directional_velocity(direction: Direction) -> Vector2:
	var velocity = Vector2()
	if direction == Direction.up:
		velocity.x = 0
		velocity.y = -SPEED
	elif direction == Direction.down:
		velocity.x = 0
		velocity.y = SPEED
	elif direction == Direction.left:
		velocity.x = -SPEED
		velocity.y = 0
	elif direction == Direction.right:
		velocity.x = SPEED
		velocity.y = 0
	return velocity


func _ready() -> void:
	position.x = 640
	position.y = 500 #10 #
	if move_state == State.moving:
		velocity = directional_velocity(move_direction)


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
		var scale = change.abs() / Vector2(TRAIL_DIMENSION, TRAIL_DIMENSION)
		scale.x = 1 if scale.x == 0 else scale.x
		scale.y = 1 if scale.y == 0 else scale.y
		print(scale)
		var newTrail = trail.instantiate() as Node2D
		trails.add_child(newTrail)
		
		#if (velocity.y == -SPEED):
		newTrail.set_global_position(global_position - change + Vector2(0, TRAIL_DIMENSION/2)) #+ Vector2(0, 20)
		newTrail.set_scale(scale)
		print('scale ', newTrail.scale)
		#newTrail.set_
		num += 1
		get_tree().paused = true
		
		#else:
			#newTrail.queue_free()
	#else:
		#get_tree().paused = true
		#pass
	
	var new_direction = calculate_direction()
	if new_direction != move_direction and new_direction is int:
		print('current', Direction.keys()[move_direction])
		print('new', Direction.keys()[new_direction])
		
		if new_direction == Direction.up:
			velocity.x = 0
			velocity.y = -SPEED
			player.set_rotation_degrees(0)
		elif new_direction == Direction.down:
			velocity.x = 0
			velocity.y = SPEED
			player.set_rotation_degrees(180)
		elif new_direction == Direction.left:
			velocity.x = -SPEED
			velocity.y = 0
			player.set_rotation_degrees(270)
		elif new_direction == Direction.right:
			velocity.x = SPEED
			velocity.y = 0
			player.set_rotation_degrees(90)
		
		move_direction = new_direction
	
	print('move')
	move_and_slide()
