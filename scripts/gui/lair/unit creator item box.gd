extends Button

var item = null
var quantity = 0

@export var max_stack = 1000
@export var disabled_on_empty = false

@export var default_icon: Texture2D
@export var slot_id : Enums.SLOT

@onready var item_count: Label = $"Item Count"


signal box_toggled(box, pressed)
signal box_mouse_entered(box)
signal box_pressed(box)

func _ready() -> void:
	update_display()

func update_display():
	var empty = is_empty()
	if !empty:
		icon = item.icon
		item_count.text = str(quantity)
	else:
		icon = default_icon
		item_count.text = ""
		
	disabled = disabled_on_empty and empty

func update_contents(new_item, new_quantity = 1):
	var returned_item
	var returned_quantity

	var leftovers = update_and_get_stack_leftovers(new_item, new_quantity)
	returned_item = leftovers[0]
	returned_quantity = leftovers[1]
	
	update_display()	
	
	return [returned_item, returned_quantity]
		
func update_and_get_stack_leftovers(new_item, new_quantity):
	var leftover_item = item
	var leftover_quantity
	
	if item == new_item:
		var total_quantity = quantity + new_quantity
		if max_stack >= total_quantity:
			leftover_item = null
			leftover_quantity = 0
			quantity = total_quantity
		else:
			leftover_quantity = total_quantity - max_stack
			quantity = max_stack
	else:
		item = new_item
		leftover_quantity = quantity
		quantity = new_quantity
	
	return [leftover_item, leftover_quantity]
		
func is_empty():
	fix_false_empty()
	return item == null

func fix_false_empty():
	if item == null:
		quantity = 0
	
func check_slot_match(slot):
	return slot == slot_id
	
func set_count_enabled(is_enabled):
	item_count.visible = is_enabled

func _on_mouse_entered() -> void:
	box_mouse_entered.emit(self)

func _on_toggled(is_button_pressed: bool) -> void:
	box_toggled.emit(self, is_button_pressed)

func _on_pressed() -> void:
	box_pressed.emit(self)
