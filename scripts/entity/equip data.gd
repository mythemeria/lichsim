extends Node

@export var gear : Gear = null
@export var actions : Array[Resource]

func _ready() -> void:
	if gear == null:
		gear = Gear.new()
		
	reload_equipment()

func reload_equipment():
	for action in actions:
		action.queue_free()
		
	actions.clear()
	
	for slot in gear.slots:
		if gear.slots[slot] != null:
			for action in gear.slots[slot].actions:
				add_action(action)
		
func change_equipment(slot_id, new_item):
	gear.slots[slot_id] = new_item
	reload_equipment()
	
func replace_gear(new_gear):
	var old_gear = gear
	gear = new_gear
	reload_equipment()
	return old_gear

#adds the actions and they will each be unique
func add_action(new_action):
	actions.append(new_action)
