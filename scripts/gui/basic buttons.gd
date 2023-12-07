extends VBoxContainer

#received signals
func _on_summon_toggled(button_pressed: bool) -> void:
	if (button_pressed):
		Cursor.cursor_mode = Cursor.CURSORMODE.summon
	else:
		Cursor.cursor_mode = Cursor.CURSORMODE.default

func _on_move_toggled(button_pressed: bool) -> void:
	if (button_pressed):
		Cursor.cursor_mode = Cursor.CURSORMODE.move
	else:
		Cursor.cursor_mode = Cursor.CURSORMODE.default
		
func _on_attack_toggled(button_pressed: bool) -> void:
	if (button_pressed):
		Cursor.cursor_mode = Cursor.CURSORMODE.attack
	else:
		Cursor.cursor_mode = Cursor.CURSORMODE.default
