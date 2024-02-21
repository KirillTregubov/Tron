extends CharacterBody2D

enum State {idle, moving}
enum Direction {up, down, left, right}

const SPEED = 250.0
const JUMP_VELOCITY = -400.0

var move_state = State.moving # State.idle
var move_direction = Direction.up
@onready var player = $Sprite2D


func _init() -> void:
	print(move_direction)
	if move_state == State.moving:
		velocity.y = -SPEED


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
	
	move_and_slide()
