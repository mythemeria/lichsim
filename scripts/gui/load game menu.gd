extends Control

var save_container_scene = preload("res://scenes/GUI/menus/main menu/save load container.tscn")

@onready var save_list: VBoxContainer = $"CenterContainer/VBoxContainer/ScrollContainer/Save List"

var threads_array : Array
var loaded_save_resources : Array[Resource]

var save_containers : Dictionary
var save_names_dict : Dictionary

var save_names_to_load_at_once = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if SaveInfo.sorted_save_file_names.is_empty():
		Debug.show_error_popup("there's no saves; how did you get here?")
	else:
		Messenger.connect("DELETE_SAVE", _on_delete_save)
		
		SaveInfo.get_sorted_save_file_names()
		
		for file_name in SaveInfo.sorted_save_file_names:
			var new_container = save_container_scene.instantiate()
			new_container.save_file_name = file_name	
			save_containers[file_name] = new_container
			save_list.add_child(new_container)
			
		var index = 0
		var count = SaveInfo.sorted_save_file_names.size()
		while index < count:
			var callable = Callable(self, "get_save_name")
			for file_name in SaveInfo.sorted_save_file_names.slice(index, index + save_names_to_load_at_once):
				var new_bound_callable = callable.bind(file_name)
				var new_thread = Thread.new()
				threads_array.append(new_thread)
				new_thread.start(new_bound_callable, Thread.PRIORITY_NORMAL)
			index += save_names_to_load_at_once
		
		while count > 0:
			await get_tree().create_timer(0.001).timeout
			for filename in save_names_dict.keys():
				var container = save_containers[filename]
				var sv_name = save_names_dict[filename]
				container.update_save_name(sv_name)
				save_names_dict.erase(filename)
				count -= 1
			
func get_save_name(filename):
	var tmp_loaded_save = SaveInfo.load_file(filename)
	if tmp_loaded_save != null:
		save_names_dict[filename] = tmp_loaded_save.save_name
	

func _on_delete_save(file_name):
	save_containers[file_name].queue_free()
	save_containers.erase(file_name)
	
func _on_back_button_pressed() -> void:
	queue_free()
	Messenger.RESTORE_MAIN_MENU.emit()
	
func _exit_tree() -> void:
	for thread in threads_array:
		thread.wait_to_finish()
