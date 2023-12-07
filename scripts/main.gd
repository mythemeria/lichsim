extends Node3D

var pause_menu_scene = preload("res://scenes/menus/pause menu.tscn")
var debug_buttons_scene = preload("res://scenes/GUI/debug/gamemode switch.tscn")

var mode_scenes = {
	Enums.GAMEPLAY_MODE.main_menu	: preload("res://scenes/menus/main menu.tscn"),
	Enums.GAMEPLAY_MODE.battle		: preload("res://scenes/modes/battle mode.tscn"),
	Enums.GAMEPLAY_MODE.map			: preload("res://scenes/modes/map mode.tscn"),
	Enums.GAMEPLAY_MODE.lair		: preload("res://scenes/modes/lair mode.tscn")
}

var mode_pause_enabled = {
	Enums.GAMEPLAY_MODE.main_menu	: false,
	Enums.GAMEPLAY_MODE.battle		: true,
	Enums.GAMEPLAY_MODE.map			: true,
	Enums.GAMEPLAY_MODE.lair		: true
}

var pause_menu

var mode_node

var current_mode

var can_show_pause = false

var default_game_mode = Enums.GAMEPLAY_MODE.map
var debug_game_mode = Enums.GAMEPLAY_MODE.lair

func _ready() -> void:
	#connect messenger signals
	Messenger.connect("SHOW_POPUP", _on_show_popup)
	Messenger.connect("MAIN_MENU_ENTER_DEBUG", enter_debug)
	Messenger.connect("NEW_GAME", new_game)
	Messenger.connect("LOAD_SAVE", load_game)
	Messenger.connect("CHANGE_GAMEPLAY_MODE", change_mode)
	Messenger.connect("ENABLE_PAUSE", _on_enable_pause)
	
	#decide what scene to load depending on if we're in debug mode
	if Debug.skip_main_menu and Debug.enabled:
		enter_debug()
	else:
		change_mode(Enums.GAMEPLAY_MODE.main_menu)		

func change_mode(new_mode):
	for child in get_children():
		child.queue_free()
		
	current_mode = new_mode
	mode_node = mode_scenes[new_mode].instantiate()
	add_child(mode_node)
	can_show_pause = mode_pause_enabled[new_mode]
		
	if Debug.enabled:
		var new_buttons = debug_buttons_scene.instantiate()
		new_buttons.current_mode = new_mode
		add_child(new_buttons)


func enter_debug():
	SaveInfo.load_debug_save()
	if SaveInfo.loaded_game_data != null:
		change_mode(debug_game_mode)
	else:
		Debug.show_error_popup("failed to load debug save")

func load_game(_filename):
	if SaveInfo.loaded_game_data != null:
		match Debug.enabled:
			true:
				change_mode(debug_game_mode)
			false:
				change_mode(default_game_mode)
	else:
		Debug.show_error_popup("failed to load save")
		
func new_game():
	match Debug.enabled:
		true:
			change_mode(debug_game_mode)
		false:
			change_mode(default_game_mode)
	
func _on_show_popup(popup):
	add_child(popup)

func _input(_event: InputEvent) -> void:
	if can_show_pause:
		if Input.is_action_just_pressed("pause menu"):
			if pause_menu == null:
				pause_menu = pause_menu_scene.instantiate()
				add_child(pause_menu)
			else:
				pause_menu.queue_free()
				pause_menu = null

func _on_enable_pause(is_enabled):
	can_show_pause = is_enabled
