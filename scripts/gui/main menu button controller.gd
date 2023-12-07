extends MarginContainer

@onready var button_container: VBoxContainer = $VBoxContainer

var load_menu_scene = preload("res://scenes/menus/load save menu.tscn")
var options_submenu_scene = preload("res://scenes/GUI/menus/options submenu.tscn")
var menu_button_scene = preload("res://scenes/GUI/menus/main menu/main menu button.tscn")
var debug_separator_scene = preload("res://scenes/GUI/menus/main menu/debug separator.tscn")

var debug_separator

func _ready() -> void:
	Messenger.connect("RESTORE_MAIN_MENU", _on_restore_main_menu)
	
	add_menu_buttons()
	

func add_button(text, function):
	var new_button = menu_button_scene.instantiate()
	new_button.text = text
	new_button.connect("pressed", function)
	button_container.add_child(new_button)

func add_menu_buttons():
	if Debug.enabled:
		add_button("ENTER DEBUG SCENE", _on_debug_pressed)
		debug_separator = debug_separator_scene.instantiate()
		button_container.add_child(debug_separator)

	if !SaveInfo.sorted_save_file_names.is_empty():
		add_button("Load Game", _on_load_pressed)
		
	add_button("New Game", _on_new_pressed)
	add_button("Options", _on_options_pressed)
	add_button("Quit", _on_quit_pressed)
	

	
func _on_restore_main_menu():
	add_menu_buttons()


#button press signals
func _on_debug_pressed():
	Messenger.MAIN_MENU_ENTER_DEBUG.emit()
			
func _on_new_pressed():
	if !SaveInfo.new_save():
		Debug.show_error_popup("failed to create new save")
			
func _on_load_pressed():
	for child in button_container.get_children():
		child.queue_free()
		
	var load_menu = load_menu_scene.instantiate()
	add_child(load_menu)
			
func _on_options_pressed():
	pass
			
func _on_quit_pressed():
	get_tree().quit()
