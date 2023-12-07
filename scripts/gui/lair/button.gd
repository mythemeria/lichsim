extends Button

signal btn_toggled(slot, pressed)
signal btn_pressed(slot)

func _on_pressed() -> void:
	btn_pressed.emit(self)


func _on_toggled(is_button_pressed: bool) -> void:
	btn_toggled.emit(self, is_button_pressed)
