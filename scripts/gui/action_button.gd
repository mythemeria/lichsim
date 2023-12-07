extends Button

var action

signal action_toggled(is_pressed, btn)

func _on_toggled(buttonpressed: bool) -> void:
	action_toggled.emit(buttonpressed, self)
