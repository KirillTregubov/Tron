extends Node2D


func scale_window():
	var window := get_window() as Window
	var retina_scale = DisplayServer.screen_get_scale()
	if (window.content_scale_factor != retina_scale):
		var relative_scale: float = retina_scale / window.content_scale_factor
		window.size = window.size*relative_scale
		window.move_to_center()


# Called when the node enters the scene tree for the first time.
func _ready():
	scale_window()


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	pass
