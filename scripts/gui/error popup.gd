extends Control

var label_text = "Error: placeholder text (bro you forgot to set the text)"
@onready var label: Label = $CenterContainer/PanelContainer/CenterContainer2/VBoxContainer/Label

func _ready() -> void:
	label.text = label_text

func _on_ok_pressed() -> void:
	queue_free()
