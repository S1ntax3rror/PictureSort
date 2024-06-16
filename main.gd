extends Node2D

@onready var bildobject = preload("res://bild_objekt.tscn")

var bildlist = []
var index = 0
@onready var pos1node = $pos1
@onready var pos2node = $pos2

var sorted_bild_list = []
var main_bild
var secondary_bild
var pos1
var pos2
var initial_click = true
var secondary_index = 0

var max_steps
var min_step_size
var step

var last_comparison = false


func _ready():
	pos1 = pos1node.global_position
	pos2 = pos2node.global_position
	max_steps = 5
	min_step_size = 1
	step = 1
	dir_contents("res://Photos-001/")
	#await get_tree().create_timer(0.5).timeout
	index = 0
	secondary_index = 1
	set_main_bild(index)
	set_secondary_bild(secondary_index)


func set_main_bild(mainindex):
	if main_bild != null:
		main_bild.visible = false
	
	main_bild = bildlist[mainindex]
	main_bild.global_position = pos1
	main_bild.visible = true

func set_secondary_bild(indexsec):
	if secondary_bild != null:
		secondary_bild.visible = false
	
	secondary_bild = bildlist[indexsec]
	secondary_bild.global_position = pos2
	secondary_bild.visible = true

func set_secondary_bild_sorted(get_index):
	if secondary_bild != null:
		secondary_bild.visible = false
	
	secondary_bild = sorted_bild_list[get_index]
	secondary_bild.global_position = pos2
	secondary_bild.visible = true
	
func dir_contents(path):
	var dir = DirAccess.open(path)
	var i = 0
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if ".import" in file_name:
				pass
			else: 
#				print("Found file: " + file_name)
#				await get_tree().create_timer(0.5).timeout
				bildlist.append(bildobject.instantiate())
				bildlist[i].path = "Photos-001/" + file_name
				bildlist[i].set_texture()
				add_child(bildlist[i])
				bildlist[i].visible = false
				i += 1
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	

func get_next_photo():
	index += 1
	if bildlist.size() > index:
		return true
	else:
		show_result()
		return false

func calc_secondary_index():
	return floori(sorted_bild_list.size()/(2*step))

func after_successful_entrie():
	sorted_bild_list.insert(secondary_index, main_bild)
	index += 1				#load next mainbild
	set_main_bild(index)
	step = 1				#reset step
	
	secondary_index = floori(sorted_bild_list.size()/2)	#load next secondary bild
	set_secondary_bild(secondary_index)

func show_result():
	print("##########################################################################")
	for element in sorted_bild_list:
		print(element.path)

func _on_right_pressed():

	#fill first two pics sorted into list
	#then get 2 new bilder, return
	if initial_click:
		initial_click = false
		sorted_bild_list.append(main_bild)
		sorted_bild_list.append(secondary_bild)
		index += 2
		secondary_index = calc_secondary_index()
		
		set_main_bild(index)
		set_secondary_bild_sorted(secondary_index)
		return
	
	
	#update comparisonpicture (comparison was better so we need a worse one)
	var old_s_index = secondary_index
	secondary_index -= calc_secondary_index()
	
	step += 1
	
	var step_size = abs(old_s_index - secondary_index)  #calc stepsize and make sure its positive
	
	if step_size < min_step_size:
		#update the comparison picture
		set_secondary_bild_sorted(secondary_index)
	else:
		if secondary_index != old_s_index:
			last_comparison = true
		else:
			sorted_bild_list.insert(secondary_index, main_bild)	#insert into list at s_index because we are allready at the minimal step
			if index < bildlist.size()-1:
				after_successful_entrie()



func _on_left_pressed():
	#fill first two pics sorted into list
	#then get 2 new bilder, return
	if initial_click:
		initial_click = false
		sorted_bild_list.append(secondary_bild)
		sorted_bild_list.append(main_bild)
		index += 2
		secondary_index = calc_secondary_index()
		
		set_main_bild(index)
		set_secondary_bild_sorted(secondary_index)
		return
	
	
	if index >= bildlist.size()-1:
		show_result()
		return
	
	#update comparisonpicture (comparison was worse so we need a better one)
	var old_s_index = secondary_index
	secondary_index += calc_secondary_index()
	
	step += 1
	
	var step_size = abs(old_s_index - secondary_index)  #calc stepsize and make sure its positive
	
	if max_steps <= step:
		after_successful_entrie()
		return
	
	##problem 1. stepsize allways < min_stepsize
	if step_size < min_step_size:
		#update the comparison picture
		set_secondary_bild_sorted(secondary_index)
	else:
		if secondary_index != old_s_index:
			last_comparison = true
		else:
			sorted_bild_list.insert(secondary_index, main_bild)	#insert into list at s_index because we are allready at the minimal step
			if index < bildlist.size()-1:
				after_successful_entrie()
