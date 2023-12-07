extends Control

var save_slots : Dictionary
var selected_save = null
var default_save_name = "save"

var save_slot_scene = preload("res://scenes/GUI/menus/save menu/save slot.tscn")

@onready var text_edit: TextEdit = $"VBoxContainer/Control/VBoxContainer/MarginContainer/MarginContainer/rename save"
@onready var save_button: Button = $"VBoxContainer/Control/VBoxContainer/MarginContainer/save button"
@onready var save_container: VBoxContainer = $"VBoxContainer/Control/VBoxContainer/Control/MarginContainer/saves panel/ScrollContainer/VBoxContainer"




func _ready() -> void:
	var new_save_name = SaveInfo.loaded_game_data.save_name
	
	text_edit.text = new_save_name
	
	Messenger.connect("DELETE_SAVE", _on_delete_save)
		
	SaveInfo.get_sorted_save_file_names()
	
	for file_name in SaveInfo.sorted_save_file_names:
		var new_save_slot = save_slot_scene.instantiate()
		new_save_slot.file_name = file_name
		save_slots[file_name] = new_save_slot
		new_save_slot.connect("save_selected", _on_save_selected)
		save_container.add_child(new_save_slot)
		new_save_slot.get_save_name_from_file()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_delete_save(filename):
	save_slots.erase(filename)
	
func _on_save_selected(slot, button_pressed):
	if button_pressed:
		if selected_save != null:
			selected_save.slot_highlight.set_pressed_no_signal(false)
		
		selected_save = slot
		text_edit.text = selected_save.save_name
	else:
		selected_save = null


func _on_save_button_pressed() -> void:
	SaveInfo.loaded_game_data.save_name = text_edit.text
	var file_name = SaveInfo.save_game()
	var new_save_slot = save_slot_scene.instantiate()
	new_save_slot.file_name = file_name
	save_slots[file_name] = new_save_slot
	new_save_slot.connect("save_selected", _on_save_selected)
	save_container.add_child(new_save_slot)
	new_save_slot.get_save_name_from_file()
	
