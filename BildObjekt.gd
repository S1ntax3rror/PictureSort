extends RigidBody2D

@onready var image = $pict

var rank = 0
var path = "res://Photos-001/69910eec-36e8-49af-b956-7906dcad1dcc.jpg"
#@onready var texture = preload("res://Photos-001/69910eec-36e8-49af-b956-7906dcad1dcc.jpg")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func set_texture():
	$pict.texture = load(path)

