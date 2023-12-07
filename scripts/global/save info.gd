extends Node

var sorted_save_file_names : Array[String]
var loaded_game_data : GameData = null
var max_saves_to_load = 50

const SAVE_GAME_PATH := "user://saves/"

func _ready() -> void:
	Messenger.connect("DELETE_SAVE", _on_delete_save)
	Messenger.connect("LOAD_SAVE", load_save)
	
	get_sorted_save_file_names()

func save_game():
	var file_name = generate_file_name()
	
	if sorted_save_file_names.has(file_name):
		Debug.show_error_popup("save file with this name already exists")
		return false
	else:
		var success = write_save(file_name)
		if success:
			return file_name
		else:
			return false
	
func write_save(file_name) -> bool:
	var err = ResourceSaver.save(loaded_game_data, SAVE_GAME_PATH + file_name)
	if err == 0:
		get_sorted_save_file_names()
		return true
	else:
		Debug.show_error_popup("can't save file error code " + str(err))
		return false
	
func load_file(filename) -> Resource:
	if ResourceLoader.exists(SAVE_GAME_PATH + filename):
		return load(SAVE_GAME_PATH + filename).duplicate()
	else:
		Debug.show_error_popup("bruh this save doesn't exist")
		return null
			
func get_sorted_save_file_names():
	var unsorted_file_names = DirAccess.get_files_at(SAVE_GAME_PATH)
	
	var mod_times_dict : Dictionary = {}
	for file_name in unsorted_file_names:
		var mod_time = FileAccess.get_modified_time(SAVE_GAME_PATH + file_name)
		
		#the previous function returns a string instead of an int if there was an error
		if typeof(mod_time) == TYPE_STRING:
			Debug.show_error_popup("failed to get file modification time")
		else:
			mod_times_dict[mod_time] = file_name
			
	var mod_times = mod_times_dict.keys()
	mod_times.sort()
	
	#clear the array first just in case
	sorted_save_file_names = []
	
	for time in mod_times:
		sorted_save_file_names.append(mod_times_dict[time])


func generate_file_name():
	var time = Time.get_datetime_dict_from_system()
	var time_string = "%s-%s-%s--%s%s%s" % [time.year, time.month, time.day, time.hour, time.minute, time.second]
	return (time_string + ".tres")

func _on_delete_save(file_name):
	OS.move_to_trash(ProjectSettings.globalize_path(SAVE_GAME_PATH + file_name))
	get_sorted_save_file_names()

func load_debug_save():
	return new_save()
	
func new_save():
	loaded_game_data = GameData.new()
	Messenger.NEW_GAME.emit()
	return (loaded_game_data != null)

func load_save(filename):
	loaded_game_data = load_file(filename)
	return (loaded_game_data != null)










#str to int conversion seems to be broken. wtf
'''func get_new_save_name(save_name):
	var tmp = save_name.split(" ", false)
	var split_save_name = []
	for string in tmp:
		split_save_name.append(string)
	
	var save_number = 1
	print(split_save_name)
	var num_str = split_save_name.pop_back()
	save_number = int(num_str) + 1
	print(split_save_name)
		
	save_name = ""
	for substring in split_save_name:
		save_name += substring + " "
	
	return save_name + str(save_number)'''
