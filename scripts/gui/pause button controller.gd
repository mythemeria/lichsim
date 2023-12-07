extends Control

var save_submenu_scene = preload("res://scenes/GUI/save screen.tscn")
var options_submenu_scene = preload("res://scenes/GUI/menus/options submenu.tscn")
var pause_submenu_scene = preload("res://scenes/GUI/menus/pause submenu.tscn")

var submenu = null

@onready var center_container: CenterContainer = $CenterContainer

func _ready() -> void:
	restore_pause_menu()

func _on_resume():
	queue_free()
	
func _on_save():
	open_submenu(save_submenu_scene)
	'''var successful = SaveInfo.save_game()
	if successful:
		Debug.show_popup("saved game successfully", false)
	else:
		Debug.show_error_popup("failed to save!", false)'''
	
func _on_options():
	open_submenu(options_submenu_scene)
	
func _on_main_menu():
	queue_free()
	SaveInfo.save_game()
	Messenger.CHANGE_GAMEPLAY_MODE.emit(Enums.GAMEPLAY_MODE.main_menu)

func _on_quit():
	var successful = SaveInfo.save_game()
	if !successful:
		var error_text = "Error: Failed to save game. Quit anyway?"
		Debug.show_yesno_popup(error_text, quit, false)
	else:
		quit()
	
func open_submenu(submenu_scene):
	clear_submenu()
	submenu = submenu_scene.instantiate()
	center_container.add_child(submenu)

func clear_submenu():
	for child in center_container.get_children():
		child.queue_free()

func restore_pause_menu():
	open_submenu(pause_submenu_scene)
		
	submenu.add_button("resume", _on_resume)
	submenu.add_button("save game", _on_save)
	submenu.add_button("options", _on_options)
	submenu.add_button("main menu", _on_main_menu)
	submenu.add_button("quit", _on_quit)
	
	
func quit():
	get_tree().quit()
	
