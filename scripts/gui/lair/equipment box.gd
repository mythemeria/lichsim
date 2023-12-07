extends Button

#[item, quantity]
var contents = [null, 0]
var max_stack = 1

@export var default_icon: Texture2D
@export var slot_id : Enums.SLOT

signal equip_slot_pressed(slot)

func _ready() -> void:
	update_display()
	
func update_display():
	if contents[0] != null:
		icon = contents[0].icon
	else:
		icon = default_icon
	
func get_contents():
	return contents
	
func update_contents(new_contents):
	contents = [new_contents[0], 1]		
	update_display()
	
func clear_contents():
	contents = [null, 0]
	update_display()
	
func is_empty():
	return contents == [null, 0]



func _on_pressed() -> void:
	equip_slot_pressed.emit(self)
