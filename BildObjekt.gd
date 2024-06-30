extends RigidBody2D

@onready var image = $pict

var rank = 0
var path = ""
var size = Vector2(1,1)
var desired_x = 200
var desired_y = 400



func set_texture():
	$pict.texture = load(path)

func rescale():
	var window_size = DisplayServer.window_get_size()
	desired_x = window_size[0]*3
	desired_y = window_size[1]*7
	
	
	var x = $pict.texture.get_width()
	var y = $pict.texture.get_height()
	size = Vector2(desired_x/x, desired_y/y)
	$pict.set_scale(size)

