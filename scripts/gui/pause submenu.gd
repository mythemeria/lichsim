extends VBoxContainer

var button_scene = preload("res://scenes/GUI/menus/main menu/main menu button.tscn")
@onready var button_container: VBoxContainer = $VBoxContainer


func add_button(text, function):
	var new_button = button_scene.instantiate()
	new_button.text = text
	new_button.connect("pressed", function)
	button_container.add_child(new_button)
