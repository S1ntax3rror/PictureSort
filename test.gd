extends Node


var ordered_list
var max_steps
var min_step_size
var s_index
var step


var index
var initial = true

func _ready():
	ordered_list = [1,2,3,4,5]
	max_steps = 5
	step = 1
	min_step_size = 1
	s_index = floor(ordered_list.size()/2)
	index = 0
	
	print(ordered_list)
	ordered_list.insert(4, 125)
	print(ordered_list)
	

