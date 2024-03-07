class_name Trail
extends Node2D

@onready var collisionShape = $StaticBody2D/CollisionShape2D as CollisionShape2D
@onready var sprite = $StaticBody2D/Sprite2D as Sprite2D


func set_color(color: Color) -> void:
	sprite.modulate = color


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
