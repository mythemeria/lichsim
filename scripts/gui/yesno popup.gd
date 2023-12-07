extends Control

var label_text = "Error: placeholder text (bro you forgot to set the text)"
@onready var label: Label = $CenterContainer/PanelContainer/MarginContainer/MarginContainer/Label
var called_function = null
var arguments = null


func _ready() -> void:
	label.text = label_text

func _on_ok_pressed() -> void:
	if called_function != null:
		if arguments != null:
			called_function.bind(arguments)
		called_function.call()
	else:
		Debug.show_error_popup("couldn't call the function because it wasn't set", false)

	queue_free()


func _on_button_pressed() -> void:
	queue_free()
