extends Node2D


@onready var bildobject = preload("res://bild_objekt.tscn")
@onready var pos1node = $pos1
@onready var pos2node = $pos2

#sets max binary search radius
@export var search_depth = 2
var depth_count = 0
var bilder_array = []

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
	#create or clean directory
	var dir: DirAccess = DirAccess.open("res://")
	if dir.dir_exists("sorted_photos"):
		dir.open("sorted_photos")
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
	dir.make_dir("sorted_photos")
	dir.open("sorted_photos")
	var folder_path = "res://sorted_photos/"
	var pic_path
	var count = 0
	for photo in sorted_bilder_array:
		pic_path = photo.path
		count += 1
		var destination_path = folder_path + str(count)+ "--" + pic_path.replace("Photos-001/", "")
		print(pic_path)
		print(destination_path)
		copyfile(pic_path, destination_path)
		

func floor_division_by_2(n):
	return floor(n/2)

func insert_left_img_into_sorted_array(insert_index, sorted_array, pict):
	sorted_array.insert(insert_index, pict)

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
	if insert_img_index > len(bilder_array)-1:
		show_results()
		return
	#update images to show
	set_pic_right(right_index)
	set_pic_left(insert_img_index)

func update_right_index(sorted_list, operations):
	var n = len(sorted_list)
	#set init i as middle elem
	var index = floor_division_by_2(n)
	#divider can be seen as the search radius of binary search
	var divider = index
	
	var has_reached_maxima = false
	#loop through operations array and travel down the binary tree
	for direction in operations:
		#if left --> picture to sort (right picture) is better than right picture
		# --> show better image through adding to the right index
		divider = floor_division_by_2(divider)
		if direction == left and divider != 0:
			index += divider
		#if right --> picture to sort (left picture) is worse than right picture
		# --> show better image through subtracting from the right index 
		elif direction == right and divider != 0:
			index -= divider
		#means, the search_radius already reched 0 
		# --> no improvement when using more operations 
		# --> use next_step
		else:
			has_reached_maxima = true
			break
	if !has_reached_maxima:
		right_index = index
	else:
		next_step()

func action_left(multiplier):
	if ended:
		return
	add_operations(left, multiplier)
	update_right_index(sorted_bilder_array, operations)
	if depth_count >= search_depth:
		next_step()
		return
	set_pic_right(right_index)
	
	print("right index" + str(right_index))
	print("left index" + str(insert_img_index))
	depth_count += 1

func action_right(multiplier):
	if ended:
		return
	add_operations(right, multiplier)
	update_right_index(sorted_bilder_array,operations)
	if depth_count >= search_depth:
		next_step()
		print("right index" + str(right_index))
		print("left index" + str(insert_img_index))
		return
	print("right index" + str(right_index))
	print("left index" + str(insert_img_index))
	set_pic_right(right_index)
	depth_count += 1


func _on_left_pressed():
	action_left(1)


func _on_left_2_toggled(toggled_on):
	action_left(2)


func _on_left_4_pressed():
	action_left(4)


func _on_right_pressed():
	action_right(1)


func _on_right_2_pressed():
	action_right(2)

func _on_right_4_pressed():
	action_right(4)



