extends Node2D


@onready var bildobject = preload("res://bild_objekt.tscn")
@onready var pos1node = $pos1
@onready var pos2node = $pos2

#sets max binary search radius
@export var search_depth = 2
var depth_count = 0
var bilder_array = []
var debug_array = [0,1]

#index to go through all images
var insert_img_index = 0

#index pointing to right picture shown
#allways in the sorted array
var right_index

#holds the sorted imgaes
var sorted_bilder_array = []

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
	right_index = 0
	
	#initialize first two pictures to show
	set_pic_left(insert_img_index)
	set_pic_right(right_index)


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
				bilder_array.append(bildobject.instantiate())
				bilder_array[i].path = "Photos-001/" + file_name
				bilder_array[i].set_texture()
				add_child(bilder_array[i])
				bilder_array[i].visible = false
				i += 1
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")


func set_pic_left(index):
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
	if len(sorted_array)-1 < insert_img_index:
		sorted_bilder_array.append(pict)
	else:
		sorted_array.insert(insert_index, pict)
		debug_array.insert(insert_index, len(sorted_array))

func next_step():
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
	set_pic_left(insert_img_index)

func update_right_index(sorted_list, operations):
	var n = len(sorted_list)
	#set init i as middle elem
	var index = floor_division_by_2(n)
	
	#count how many operations have been used to tell if they should be considered or not
	var directions_to_count = 0
	
	#divider can be seen as the search radius of binary search
	var divider = index
	
	var has_reached_maxima = false
	#loop through operations array and travel down the binary tree
	for direction in operations:
		directions_to_count += 1
		#if left --> picture to sort (right picture) is better than right picture
		# --> show better image through adding to the right index
		divider = floor_division_by_2(divider)
		if direction == left and divider != 0:
			print("direction == left and divider != 0")
			index += divider
		#if right --> picture to sort (left picture) is worse than right picture
		# --> show better image through subtracting from the right index 
		elif direction == right and divider != 0:
			print("direction == right and divider != 0")
			index -= divider
		# edgecase #1 the element n-1 can in some cases not be reached by adding
		# up floordivisions of n --> we need to keep adding 1 untill we reach n-1
		# if we only ever add and never subtract 
		elif direction == left and divider == 0:
			print("direction == left and divider == 0")
			var directions_counter = 0
			for direction_2 in operations:
				directions_counter += 1
				if directions_to_count <= directions_counter:
					break
				if direction_2 == right:
					print("direction_2 == right")
					has_reached_maxima = true
					break
			#has to be <= not < due to inserting at this index --> appending at index n in the edgecaes
			if !has_reached_maxima and index <= len(sorted_bilder_array)-1:
				print("!has_reached_maxima and index < len(sorted_bilder_array)-1")
				index += 1
			elif index >= len(sorted_bilder_array)-1:
				has_reached_maxima = true
			else:
				has_reached_maxima = true
				index += 1
				right_index = index
		# edgecase #2 the element 0 can in some cases not be reached by subtracting
		# floordivisions of n --> we need to keep subtracting 1 untill we reach 0
		# if we only ever subtract and never add
		elif direction == right and divider == 0:
			print("direction == right and divider == 0")
			var directions_counter = 0
			for direction_2 in operations:
				directions_counter += 1
				if directions_to_count <= directions_counter:
					break
				if direction_2 == left:
					print("direction_2 == left")
					has_reached_maxima = true
					break
			if !has_reached_maxima and index > 0:
				print("!has_reached_maxima and index < len(sorted_bilder_array)-1")
				index -= 1
			elif index <= 0:
				has_reached_maxima = true
			else:
				has_reached_maxima = true
				index -= 1
				right_index = index
		#means, the search_radius already reched 0 
		# --> no improvement when using more operations 
		# --> use next_step
		else:
			print("else")
			has_reached_maxima = true
			break
	if !has_reached_maxima:
		right_index = index
	else:
		next_step()
		skip_remaining = true

func action_left(multiplier):
	skip_remaining = false
	if ended:
		return
	add_operations(left, multiplier)
	update_right_index(sorted_bilder_array, operations)
	
	print_sorted_arr()
	
	if skip_remaining:
		return
	if depth_count >= search_depth:
		next_step()
		return
	set_pic_right(right_index)
	
	print("right index" + str(right_index))
	print("left index" + str(insert_img_index))
	depth_count += 1

func action_right(multiplier):
	skip_remaining = false
	if ended:
		return
	add_operations(right, multiplier)
	update_right_index(sorted_bilder_array,operations)
	if skip_remaining:
		return
	if depth_count >= search_depth:
		next_step()
		print("reset Due to DEPTH")
		print("right index" + str(right_index))
		print("left index" + str(insert_img_index))
		return
	print("NORMAL SORT")
	print("right index" + str(right_index))
	print("left index" + str(insert_img_index))
	set_pic_right(right_index)
	depth_count += 1
	print_sorted_arr()


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
	set_pic_left(insert_img_index)
	right_index = floor_division_by_2(len(sorted_bilder_array))
	set_pic_right(right_index)
	print("initial array looks like:" + sorted_bilder_array[0].path + ", " + sorted_bilder_array[1].path)


func print_sorted_arr():
	for elem in sorted_bilder_array:
		print(elem.path)

func _on_left_pressed():
	if initial_click:
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





