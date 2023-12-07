extends Node

var enabled = true

var skip_main_menu = false
var show_spawn_points = false

var error_popup_scene = preload("res://scenes/GUI/debug/error popup.tscn")
var yesno_popup_scene = preload("res://scenes/GUI/debug/yesno popup.tscn")
var debug_overlay_scene = preload("res://scenes/gui/debug/debug overlay.tscn")
var debug_message_entry_scene = preload("res://scenes/gui/debug/debug message entry.tscn")
var debug_message_box_scene = preload("res://scenes/GUI/debug/debug message box.tscn")

var debug_overlay = null
var debug_message_box = null

func _ready() -> void:
	toggle_debug(enabled)

func show_error_popup(popup_text, debug_only=false):
	if (debug_only and Debug.enabled) or !debug_only:
		var popup_instance = error_popup_scene.instantiate()
		popup_instance.label_text = "Error: " + popup_text
		Messenger.SHOW_POPUP.emit(popup_instance)
		
func show_popup(popup_text, debug_only=false):
	if (debug_only and Debug.enabled) or !debug_only:
		var popup_instance = error_popup_scene.instantiate()
		popup_instance.label_text = popup_text
		Messenger.SHOW_POPUP.emit(popup_instance)
		
func show_yesno_popup(popup_text, function_to_call, debug_only=false):
	if (debug_only and Debug.enabled) or !debug_only:
		var popup_instance = yesno_popup_scene.instantiate()
		popup_instance.label_text = popup_text
		popup_instance.called_function = function_to_call
		Messenger.SHOW_POPUP.emit(popup_instance)
		return popup_instance
		
		
func add_error_message(message):
	if enabled:
		if debug_message_box == null:
			debug_message_box = debug_message_box_scene.instantiate()
			Messenger.SHOW_POPUP.emit(debug_message_box)
		var new_message_box = debug_message_entry_scene.instantiate()
		new_message_box.message = message		
		debug_message_box.add_child(new_message_box)
		
func toggle_debug(toggle):
	enabled = toggle
	if enabled:
		debug_message_box = debug_message_box_scene.instantiate()
		Messenger.SHOW_POPUP.emit(debug_message_box)
		debug_overlay = debug_overlay_scene.instantiate()
		Messenger.SHOW_POPUP.emit(debug_overlay)
	else:
		if debug_overlay != null:
			debug_overlay.queue_free()
			debug_overlay = null
		if debug_message_box != null:
			debug_message_box.queue_free()
			debug_message_box = null
		
		
