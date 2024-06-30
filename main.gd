extends Node2D


@onready var bildobject = preload("res://bild_objekt.tscn")
@onready var pos1node = $pos1
@onready var pos2node = $pos2

#sets max binary search radius
@export var search_depth = 10
var depth_count = 0
var bilder_array = []
var debug_array = [0,1]

#index to go through all images
var insert_img_index = 0


#holds the sorted imgaes
var sorted_bilder_array = []
var clear_sorted_bilder_array = []

#hold the operations done temporarely
var operations = []
#directions
var left = "left"
var right = "right"

var skip_remaining = false
var initial_click = true

#stores the positions of the left and right img
var pos_left
var pos_right
var ended = false

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().get_root().size_changed.connect(resize) 
	#°DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	#init left and right picture positions
	pos_left = pos1node.global_position
	pos_right = pos2node.global_position
	
	#read all pictures from folder Photos-001
	#load them as obj. into bilder_array
	dir_contents("res://Photos-001/")
	
	#no images found --> exit
	if len(bilder_array) == 0:
		print("ERROR no images found")
		get_tree().quit()

	#initialize sorted_bilder_array with the first element of bilder_array
	sorted_bilder_array.append(bilder_array[0])
	#set iteration variables correct
	insert_img_index = 1
	
	#initialize first two pictures to show
	set_pic_left(insert_img_index, 0)
	set_pic_right(0)

func resize():
	for pic in bilder_array:
		pic.rescale()

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
				print("Found file: " + file_name)
#				await get_tree().create_timer(0.5).timeout
				bilder_array.append(bildobject.instantiate())
				bilder_array[i].path = "Photos-001/" + file_name
				bilder_array[i].set_texture()
				add_child(bilder_array[i])
				bilder_array[i].visible = false
				i += 1
			file_name = dir.get_next()
		
		for pic in bilder_array:
			pic.rescale()
		
	else:
		print("An error occurred when trying to access the path.")


func set_pic_left(index, right_index):
	bilder_array[index].global_position = pos_left
	
	#set correct picture to visible
	bilder_array[index].visible = true
	if index > 0 and bilder_array[index -1] != sorted_bilder_array[right_index]:
		bilder_array[index-1].visible = false

func set_pic_right(index):
	sorted_bilder_array[index].global_position = pos_right
	
	#reset all to invisible
	for elem in sorted_bilder_array:
		elem.visible = false
	
	#set correct picture to visible
	sorted_bilder_array[index].visible = true

func add_operations(direction, multiplier):
	for i in range(multiplier):
		operations.append(direction)

func clear_operations():
	operations = []

func copyfile(source_file_path, destination):
	var file = FileAccess.open(source_file_path, FileAccess.READ)
	if file:
		var destination_file = FileAccess.open(destination, FileAccess.WRITE)
		if destination_file:
			destination_file.store_buffer(file.get_buffer(file.get_length()))
			destination_file.close()
			file.close()
			print("File copied successfully.")
		else:
			print("Error opening destination file for writing.")
	else:
		print("Source file does not exist or cannot be opened.")

func show_results():
	print("list sorted")
	ended = true
	print(debug_array)
	#create or clean directory
	var dir: DirAccess = DirAccess.open("res://")
	if dir.dir_exists("sorted_photos"):
		dir = DirAccess.open("res://sorted_photos")
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir() == false:
				var file_path = "res://sorted_photos" + "/" + file_name
				dir.remove(file_path)
				print("Removed file: ", file_path)
			file_name = dir.get_next()
		dir.list_dir_end()
		print("All files removed successfully.")
	else:
		dir.make_dir("sorted_photos")
	dir = DirAccess.open("sorted_photos")
	var folder_path = "res://sorted_photos/"
	var pic_path
	var count = len(sorted_bilder_array)
	for photo in sorted_bilder_array:
		pic_path = photo.path
		var destination_path = folder_path + str(count)+ "--" + pic_path.replace("Photos-001/", "")
		print(pic_path)
		print(destination_path)
		copyfile(pic_path, destination_path)
		count -= 1

func floor_division_by_2(n):
	return floor(n/2)

func insert_left_img_into_sorted_array(insert_index, sorted_array, pict):
	if len(sorted_array)-1 < insert_index:
		sorted_bilder_array.append(pict)
	else:
		sorted_array.insert(insert_index, pict)
		debug_array.insert(insert_index, len(sorted_array))

func next_step(right_index):
	if insert_img_index > len(bilder_array)-1:
		show_results()
		return
	#insert left img at index right_img in sorted array
	insert_left_img_into_sorted_array(right_index, sorted_bilder_array, bilder_array[insert_img_index])
	#reset operations
	clear_operations()
	#reset depth_count
	depth_count = 0
	#update insert_img_index
	insert_img_index += 1
	right_index = floor_division_by_2(len(sorted_bilder_array))
	#check if results should be loaded
	if insert_img_index > len(bilder_array)-1 or len(sorted_bilder_array) == len(bilder_array):
		show_results()
		return
	#update images to show
	set_pic_right(right_index)
	set_pic_left(insert_img_index, right_index)

func update_right_index(sorted_list):
	
	var processed_operations = []
	var n = len(sorted_list)
	var divider = floor_division_by_2(n)
	var pos = divider
	var old_pos = pos
	var found_final_position = false
	
	for operation in operations:
		processed_operations.append(operation)
		divider = floor_division_by_2(divider)
		
		if operation == left:
			if divider != 0:
				pos += divider
				
				#Check if out of index
				if pos > n-1:
					found_final_position = true
					pos = old_pos
					break
			
			else:
				# if only moved into one direction,
				# edge case applies --> +1 needed
				# otherwise end found
				
				# check if only left:
				var only_left = true
				for op in processed_operations:
					if op != left:
						only_left = false
						break
				
				if !only_left:
					found_final_position = true
					break
				
				pos += 1
				
				if pos > n-1:
					found_final_position = true
					break
		
		elif operation == right:
			
			if  divider != 0:
				pos -= divider
				
				if pos < 0:
					found_final_position = true
					pos = old_pos
					break
			
			else:
				var only_right = true
				
				for op in processed_operations:
					if op != right:
						only_right = false
						break
				
				if !only_right:
					found_final_position = true
					break
				
				pos -= 1
				
				if pos < 0:
					found_final_position = true
					break
		
		old_pos = pos
		
		
	if !found_final_position:
		set_pic_right(pos)
		return
	
	if operations[0] == right:
		pos += 1
	next_step(pos)

func update_clearlist():
	clear_sorted_bilder_array = []
	for pic in sorted_bilder_array:
		clear_sorted_bilder_array.append(pic.path)


func action_left(multiplier):
	update_clearlist()
	skip_remaining = false
	if ended:
		return
	add_operations(left, multiplier)
	update_right_index(sorted_bilder_array)


func action_right(multiplier):
	update_clearlist()
	skip_remaining = false
	if ended:
		return
	add_operations(right, multiplier)
	update_right_index(sorted_bilder_array)


func init_order(direction):
	initial_click = false
	if direction == left:
		sorted_bilder_array.append(bilder_array[1])
	else:
		sorted_bilder_array.append(bilder_array[0])
		sorted_bilder_array[0] = bilder_array[1]
	insert_img_index += 1
	if insert_img_index > len(bilder_array)-1:
		show_results()
		return
	set_pic_left(insert_img_index, 0)
	var right_index = floor_division_by_2(len(sorted_bilder_array))
	set_pic_right(right_index)
	print("initial array looks like:" + sorted_bilder_array[0].path + ", " + sorted_bilder_array[1].path)


func print_sorted_arr():
	for elem in sorted_bilder_array:
		print(elem.path)

func _on_left_pressed():
	if initial_click:
		update_clearlist()
		init_order(left)
	else:
		action_left(1)


func _on_left_2_pressed():
	if initial_click:
		init_order(left)
	else:
		action_left(2)


func _on_left_4_pressed():
	if initial_click:
		init_order(left)
	else:
		action_left(4)


func _on_right_pressed():
	if initial_click:
		init_order(right)
	else:
		action_right(1)


func _on_right_2_pressed():
	if initial_click:
		init_order(right)
	else:
		action_right(2)

func _on_right_4_pressed():
	if initial_click:
		init_order(right)
	else:
		action_right(4)





