extends Button

var save_file_name

signal on_save_pressed(file_name)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_btn_pressed)
	
func _on_btn_pressed():
	Messenger.LOAD_SAVE.emit(save_file_name)
