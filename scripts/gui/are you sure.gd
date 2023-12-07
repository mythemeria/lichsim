extends Control

var save_file_name

func _on_ok_pressed() -> void:
	Messenger.DELETE_SAVE.emit(save_file_name)
	queue_free()


func _on_cancel_pressed() -> void:
	queue_free()
