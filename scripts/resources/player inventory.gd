extends Resource
class_name PlayerInventory

#array of arrays [[item, quantity]]
@export var inv_slot_data : Array
@export var equipment_unlock_data : Dictionary
@export var souls : int = 0
@export var unemployed_skeletons : int = 0
@export var generals : Array
@export var army_data : Dictionary
@export var unit_presets : Dictionary

var max_stack_size = 1000

func enter_inventory(entering_item, item_count):
	inv_slot_data.append([entering_item, item_count])
	Messenger.INVENTORY_UPDATED.emit()
	
func leave_inventory(inv_slot_id):
	if inv_slot_data.has(inv_slot_id):
		inv_slot_data[inv_slot_id] = [null, 0]
		Messenger.INVENTORY_UPDATED.emit()

func find_first_empty_slot():
	var index = inv_slot_data.find([null, 0])
	
	if index != -1:
		return index
	else:
		inv_slot_data.append([null, 0])
		print("make sure to check that this returns the correct index!")
		Messenger.INVENTORY_UPDATED.emit()
		return inv_slot_data.size() - 1
