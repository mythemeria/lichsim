extends Control

#[item, quantity]
var contents : Item = null


@onready var item_icon: TextureRect = $"Item Icon"

signal box_clicked(box, event)

func _ready() -> void:
	update_display()
	
func update_display():
	if contents != null:
		item_icon.texture = contents.icon
	
func get_contents():
	return contents

func _on_gui_input(event: InputEvent) -> void:
	box_clicked.emit(self, event)
