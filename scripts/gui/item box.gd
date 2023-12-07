extends Button

#[item, quantity]
var contents = [null, 0]
var max_stack = 1000

@onready var item_count: Label = $"Item Count"

signal box_input_event(box)
signal box_mouse_entered(box)

func _ready() -> void:
	update_display()
	
func update_display():
	var item = contents[0]
	var quantity = contents[1]
	if contents[0] != null:
		icon = item.icon
		if contents[0].stackable:
			item_count.text = str(quantity)
		else:
			item_count.text = ""
	else:
		icon = null
		item_count.text = ""
	
func get_contents():
	return contents
	
func update_contents(new_contents):
	var item = contents[0]
	var new_item = new_contents[0]
	var quantity = contents[1]
	var new_quantity = new_contents[1]
	
	var leftovers = [null, 0]
	
	if item == new_item and item != null:
		var total_quantity = quantity + new_quantity
		if total_quantity > max_stack:
			contents = [item, max_stack]
			leftovers = [item, total_quantity - max_stack]
		else:
			contents = [item, total_quantity]
	else:
		leftovers = contents
		contents = new_contents
		
	update_display()
	return leftovers

	
func clear_contents():
	var tmp = contents
	contents = [null, 0]
	update_display()
	return tmp

func is_empty():
	return contents == [null, 0]

func _on_gui_input(event: InputEvent) -> void:
	box_input_event.emit(self, event)


func _on_mouse_entered() -> void:
	box_mouse_entered.emit(self)
