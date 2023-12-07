extends MarginContainer

@onready var slot_highlight: Button = $"slot highlight"
@onready var save_label: Label = $"MarginContainer/save name"
@onready var delete_button: Button = $"MarginContainer2/delete save"

var save_name : String
var file_name : String

signal save_selected(slot, button_pressed)

	

func _on_delete_save_pressed() -> void:
	Debug.show_yesno_popup("Are you sure you want to delete this save file?", delete_save)
	
func delete_save():
	Messenger.DELETE_SAVE.emit(file_name)
	queue_free()
	
func update_save_name(new_save_name):
	save_name = new_save_name
	save_label.text = new_save_name

func get_save_name(filename):
	var tmp_loaded_save = SaveInfo.load_file(filename)
	if tmp_loaded_save != null:
		save_name = tmp_loaded_save.save_name
	tmp_loaded_save.queue_free()

func _on_slot_highlight_toggled(button_pressed: bool) -> void:
	save_selected.emit(self, button_pressed)
	
func get_save_name_from_file():
	var new_thread = Thread.new()
	var callable = Callable(self, "get_save_name")
	var new_bound_callable = callable.bind(file_name)
	new_thread.start(new_bound_callable, Thread.PRIORITY_NORMAL)
	new_thread.wait_to_finish()
	save_label.text = save_name
