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
	

func button_left_better():
	if initial:
		pass 	#fill first two pics sorted into list
				#then get 2 new bilder, return
	#next step
	step += 1
	#update comparisonpicture (comparison was worse so we need a better one)
	var old_s_index = s_index
	s_index += floori(ordered_list.size()/(2*step))
	
	var step_size = abs(old_s_index - s_index)  #calc stepsize and make sure its positive
	if step_size < min_step_size:
		pass		#if s_index != old_s_index: --> last comparison = true
					#insert into list at s_index because we are allready at the minimal step
	else:
		pass #update the comparison picture
	
func button_right_better():
	if initial:
		pass 	#fill first two pics sorted into list
				#then get 2 new bilder, return
	
	#next step
	step += 1
	#update comparisonpicture (comparison was better so we need a worse one)
	var old_s_index = s_index
	s_index -= floor(ordered_list.size()/(2*step))
	
	var step_size = abs(old_s_index - s_index)  #calc stepsize and make sure its positive
	if step_size < min_step_size:
		pass		#if s_index != old_s_index: --> last comparison = true
					#insert into list at s_index because we are allready at the minimal step
	else:
		pass #update the comparison picture
