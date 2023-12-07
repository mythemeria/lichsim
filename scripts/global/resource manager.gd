extends Node

var RESOURCE_PATH = "res://resources/"
var ITEM_PATH = "items/"

var items : Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var path = RESOURCE_PATH + ITEM_PATH
	var item_file_names = DirAccess.get_files_at(path)
	for file_name in item_file_names:
		if ResourceLoader.exists(path + file_name):
			items.append(load(path + file_name))
			
	Messenger.connect("NEW_GAME", _on_new_game)
	
func _on_new_game():
	var unlock_data = SaveInfo.loaded_game_data.inventory.equipment_unlock_data
	for item in items:
		if item.is_equipable:
			unlock_data[item] = Debug.enabled
			

