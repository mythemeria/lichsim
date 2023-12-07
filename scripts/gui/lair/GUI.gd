extends Control

var unit_creator_scene = preload("res://scenes/GUI/lair/unit creation.tscn")
var inventory_scene = preload("res://scenes/menus/player inventory.tscn")

var active_menu = null
var active_menu_id = MENU_ID.none

enum MENU_ID {
	none,
	inventory,
	unit_creator
}

func _on_button_pressed() -> void:
	active_menu = unit_creator_scene.instantiate()
	active_menu_id = MENU_ID.unit_creator
	add_child(active_menu)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("open inventory"):
			if active_menu_id == MENU_ID.inventory:
				active_menu.queue_free()
				active_menu = null
				active_menu_id = MENU_ID.none
			elif active_menu_id == MENU_ID.none:
				active_menu = inventory_scene.instantiate()
				active_menu_id = MENU_ID.inventory
				add_child(active_menu)
		if Input.is_action_just_released("cancel"):
			if active_menu != null:
				active_menu.queue_free()
				active_menu = null
				active_menu_id = MENU_ID.none
				Messenger.ENABLE_PAUSE.emit(true)
				
			
