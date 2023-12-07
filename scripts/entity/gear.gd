extends Node

@export var gear : Gear = null

func _ready() -> void:
	if gear == null:
		gear = Gear.new()
		
	for slot in gear.slots:
		if gear[slot] != null:
			gear[slot].model

'''##to unequip, make item = null
func equip_item(slot, item):
	if item:
		if item.slot == slot and item.body_types.has(gear.body_type):
			var new_item = item.scene.instantiate()
			add_child(new_item)
			gear[slot] = item
			return true
		else:
			return false
	else:
		gear[slot].queue_free()
		return true
		
func equip_children():
	for child in get_children():
		if gear[child.slot] != null:
			print("trying to equip children but multiple items occupy the same slot. skipping")
		elif child.body_types.has(gear.body_type):
			gear[child.slot] = child
		else:
			print("trying to add an equipment child on the incorrect body type. skipping")
	for action in gear.slots[Enums.SLOT.weapon].actions:
		action.entity_ref = self.get_parent()'''
		

