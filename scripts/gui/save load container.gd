extends Control

var save_file_name = ""
var save_name = ""

@onready var save_label: Label = $"HBoxContainer/Save Label"

var popup_scene = preload("res://scenes/GUI/menus/main menu/are you sure.tscn")

func _ready() -> void:
	save_label.text = save_name

func _on_load_pressed() -> void:
	Messenger.LOAD_SAVE.emit(save_file_name)

func _on_delete_pressed() -> void:
	var popup_instance = popup_scene.instantiate()
	popup_instance.save_file_name = save_file_name
	Messenger.SHOW_POPUP.emit(popup_instance)

func update_save_name(new_text):
	save_name = new_text
	save_label.text = save_name
