extends Control

var inventory_ref
var unit_name = null
var gear = Gear.new()
var min_rows = 11
var selected_save = null

var item_box_scene = preload("res://scenes/GUI/inventory/item box.tscn")
var save_slot_scene = preload("res://scenes/GUI/lair/button.tscn")

@onready var equipment_container: GridContainer = $CenterContainer/HBoxContainer/Panel/margin/HBoxContainer/ScrollContainer/GridContainer
@onready var save_button: Button = $CenterContainer/HBoxContainer/Panel/margin/HBoxContainer/vbox/CenterContainer/HBoxContainer/Button
@onready var unit_name_text_edit: TextEdit = $CenterContainer/HBoxContainer/Panel/margin/HBoxContainer/vbox/CenterContainer/HBoxContainer/TextEdit
@onready var save_slot_container: VBoxContainer = $CenterContainer/HBoxContainer/Panel2/MarginContainer/ScrollContainer/VBoxContainer
@onready var new_preset_button: Button = $CenterContainer/HBoxContainer/Panel2/MarginContainer/ScrollContainer/VBoxContainer/Button

@onready var equip_dict = {
	Enums.SLOT.head		: $CenterContainer/HBoxContainer/Panel/margin/HBoxContainer/vbox/Equip/mar/slots2/helmet,
	Enums.SLOT.chest	: $CenterContainer/HBoxContainer/Panel/margin/HBoxContainer/vbox/Equip/mar/slots2/chest,
	Enums.SLOT.legs		: $CenterContainer/HBoxContainer/Panel/margin/HBoxContainer/vbox/Equip/mar/slots2/legs,
	Enums.SLOT.feet		: $CenterContainer/HBoxContainer/Panel/margin/HBoxContainer/vbox/Equip/mar/slots2/boots,
	Enums.SLOT.cape		: $CenterContainer/HBoxContainer/Panel/margin/HBoxContainer/vbox/Equip/mar/slots1/cape,
	Enums.SLOT.ring		: $CenterContainer/HBoxContainer/Panel/margin/HBoxContainer/vbox/Equip/mar/slots1/ring,
	Enums.SLOT.amulet	: $CenterContainer/HBoxContainer/Panel/margin/HBoxContainer/vbox/Equip/mar/slots1/amulet,
	Enums.SLOT.hands	: $CenterContainer/HBoxContainer/Panel/margin/HBoxContainer/vbox/Equip/mar/slots1/gloves,
	Enums.SLOT.weapon	: $CenterContainer/HBoxContainer/Panel/margin/HBoxContainer/vbox/Equip/mar/HBoxContainer/weapon,
	Enums.SLOT.shield	: $CenterContainer/HBoxContainer/Panel/margin/HBoxContainer/vbox/Equip/mar/HBoxContainer/shield
}

func _ready() -> void:
	inventory_ref = SaveInfo.loaded_game_data.inventory
	gear.body_type = Enums.BODY_TYPE.humanoid
	
	Messenger.ENABLE_PAUSE.emit(false)
	
	add_item_boxes()
	fill_equip_slots_from_gear()
	
	for key in inventory_ref.unit_presets.keys():
		add_save_slot(key)
	
	
func fill_equip_slots_from_gear():
	if selected_save != null:
		unit_name_text_edit.text = selected_save.text
		unit_name = selected_save.text		
	else:
		unit_name_text_edit.text = "unit name"
		unit_name = null
		
	for slot in equip_dict.keys():
		equip_dict[slot].set_count_enabled(false)
		equip_dict[slot].update_contents(gear.slots[slot])
		
	
func add_item_boxes():
	var columns = equipment_container.columns
	var rows = max(min_rows, ceil(inventory_ref.inv_slot_data.size()/columns))
	
	var index = 0
	for item in inventory_ref.equipment_unlock_data.keys():
		if inventory_ref.equipment_unlock_data[item]:
			add_box(item)
			index += 1
		
	while index < rows * columns:
		add_box(null)
		index += 1
	
func add_box(item):
	var new_item_box = item_box_scene.instantiate()
	new_item_box.toggle_mode = false
	new_item_box.connect("box_pressed", _on_item_box_pressed)
	new_item_box.disabled_on_empty = true
	equipment_container.add_child(new_item_box)
	new_item_box.set_count_enabled(false)
	new_item_box.update_contents(item)
	
func add_save_slot(text):
	var new_save_slot = save_slot_scene.instantiate()
	new_save_slot.text = text
	new_save_slot.connect("btn_toggled", _on_save_slot_toggled)
	save_slot_container.add_child(new_save_slot)
	
func _on_item_box_pressed(box):
	if !box.is_empty():
		if gear.slots[box.item.gear_slot] != box.item:
			equip_dict[box.item.gear_slot].update_contents(box.item)
			gear.slots[box.item.gear_slot] = box.item
		else:
			gear.slots[box.item.gear_slot] = null
			equip_dict[box.item.gear_slot].update_contents(null, 0)
	
func _on_save_slot_toggled(save_slot, is_pressed):
	if is_pressed:
		if save_slot != selected_save and selected_save != null:
			selected_save.set_pressed_no_signal(false)
		selected_save = save_slot
		gear = inventory_ref.unit_presets[save_slot.text].duplicate()
		fill_equip_slots_from_gear()
	else:
		_on_new_preset()

func _on_new_preset() -> void:
	if selected_save != null:
		selected_save.set_pressed_no_signal(false)
	selected_save = null
	gear = Gear.new()
	fill_equip_slots_from_gear()

func _on_equip_slot_pressed(slot):
	pass

func _on_text_changed() -> void:
	unit_name = unit_name_text_edit.text

func _on_save_pressed() -> void:
	if unit_name != null:
		if !inventory_ref.unit_presets.has(unit_name):
			add_save_slot(unit_name)
			save_gear()			
		elif selected_save != null:
			if selected_save.text == unit_name:
				save_gear()
			elif inventory_ref.unit_presets.has(unit_name):
				Debug.show_yesno_popup("This will overwrite an existing preset. Save anyway?", save_gear)
		else:
			Debug.show_yesno_popup("This will overwrite an existing preset. Save anyway?", save_gear)
			
func save_gear():
	inventory_ref.unit_presets[unit_name] = gear
	gear = Gear.new()
	fill_equip_slots_from_gear()
	if selected_save != null:
		selected_save.set_pressed_no_signal(false)
		selected_save = null

func _exit_tree() -> void:
	Messenger.ENABLE_PAUSE.emit(true)

































'''extends Control

var inventory_ref
var inv_dict : Dictionary
var unit_name = null
var preset_dict: Dictionary
var open_preset = null
var open_preset_index = null

var item_box_scene = preload("res://scenes/GUI/inventory/toggle item box.tscn")
var save_slot_scene = preload("res://scenes/GUI/lair/button.tscn")

@onready var inventory_container: GridContainer = $CenterContainer/HBoxContainer/Panel/margin/HBoxContainer/ScrollContainer/GridContainer
@onready var save_button: Button = $CenterContainer/HBoxContainer/Panel/margin/HBoxContainer/vbox/CenterContainer/HBoxContainer/Button
@onready var unit_name_text_edit: TextEdit = $CenterContainer/HBoxContainer/Panel/margin/HBoxContainer/vbox/CenterContainer/HBoxContainer/TextEdit
@onready var save_slot_container: VBoxContainer = $CenterContainer/HBoxContainer/Panel2/MarginContainer/ScrollContainer/VBoxContainer
@onready var new_preset_button: Button = $CenterContainer/HBoxContainer/Panel2/MarginContainer/ScrollContainer/VBoxContainer/Button

@onready var equip_dict = {
	Enums.SLOT.head		: $CenterContainer/HBoxContainer/Panel/margin/HBoxContainer/vbox/Equip/mar/slots2/helmet,
	Enums.SLOT.chest	: $CenterContainer/HBoxContainer/Panel/margin/HBoxContainer/vbox/Equip/mar/slots2/chest,
	Enums.SLOT.legs		: $CenterContainer/HBoxContainer/Panel/margin/HBoxContainer/vbox/Equip/mar/slots2/legs,
	Enums.SLOT.feet		: $CenterContainer/HBoxContainer/Panel/margin/HBoxContainer/vbox/Equip/mar/slots2/boots,
	Enums.SLOT.cape		: $CenterContainer/HBoxContainer/Panel/margin/HBoxContainer/vbox/Equip/mar/slots1/cape,
	Enums.SLOT.ring		: $CenterContainer/HBoxContainer/Panel/margin/HBoxContainer/vbox/Equip/mar/slots1/ring,
	Enums.SLOT.amulet	: $CenterContainer/HBoxContainer/Panel/margin/HBoxContainer/vbox/Equip/mar/slots1/amulet,
	Enums.SLOT.hands	: $CenterContainer/HBoxContainer/Panel/margin/HBoxContainer/vbox/Equip/mar/slots1/gloves,
	Enums.SLOT.weapon	: $CenterContainer/HBoxContainer/Panel/margin/HBoxContainer/vbox/Equip/mar/HBoxContainer/weapon,
	Enums.SLOT.shield	: $CenterContainer/HBoxContainer/Panel/margin/HBoxContainer/vbox/Equip/mar/HBoxContainer/shield
}

var equip_items_dict = {
	Enums.SLOT.head		: null,
	Enums.SLOT.chest	: null,
	Enums.SLOT.legs		: null,
	Enums.SLOT.feet		: null,
	Enums.SLOT.cape		: null,
	Enums.SLOT.amulet	: null,
	Enums.SLOT.hands	: null,
	Enums.SLOT.ring		: null,
	Enums.SLOT.weapon	: null,
	Enums.SLOT.shield	: null
}

var gear = Gear.new()

var min_rows = 11

func _ready() -> void:
	gear.body_type = Enums.BODY_TYPE.humanoid
	
	Messenger.connect("INVENTORY_UPDATED", _on_inventory_updated)
	Messenger.ENABLE_PAUSE.emit(false)
	
	inventory_ref = SaveInfo.loaded_game_data.inventory
		
	add_slots()
	
	add_saves()
		
	for box in equip_dict.values():
		box.connect("equip_slot_pressed", _on_equip_slot_pressed)

func _on_box_toggled(box, is_pressed):
	var slot_id = box.contents[0].gear_slot
	if is_pressed:
		equip_dict[slot_id].update_contents(box.contents)
		if equip_items_dict[slot_id] != null:
			equip_items_dict[slot_id].set_pressed_no_signal(false)
		equip_items_dict[slot_id] = box
	else:
		equip_dict[slot_id].update_contents([null, 0])
		equip_items_dict[slot_id] = null
	
					
func _on_equip_slot_pressed(slot):
	pass
	
	
func _on_inventory_updated():
	add_slots()

func add_slots():
	var columns = inventory_container.columns
	var rows = max(min_rows, ceil(inventory_ref.inv_slot_data.size()/columns))
	
	var inv_size = inventory_ref.inv_slot_data.size()
	var index = inv_dict.size()
	while index < inv_size:
		var new_item_box = item_box_scene.instantiate()
		new_item_box.contents = inventory_ref.inv_slot_data[index]
		new_item_box.connect("box_toggled", _on_box_toggled)
		inv_dict[new_item_box] = index
		inventory_container.add_child(new_item_box)
		index += 1
	
	var inv_dict_values = inv_dict.values()
	index = 0
	while index < rows * columns:
		if inventory_ref.inv_slot_data.size() <= index:
			inventory_ref.inv_slot_data.append([null, 0])
			
		if !inv_dict_values.has(index):
			var new_item_box = item_box_scene.instantiate()
			new_item_box.contents = inventory_ref.inv_slot_data[index]
			new_item_box.connect("box_toggled", _on_box_toggled)
			inv_dict[new_item_box] = index
			inventory_container.add_child(new_item_box)
		else:
			var item_box = inv_dict.find_key(index)
			item_box.contents = inventory_ref.inv_slot_data[index]
		index += 1
	
func add_saves():
	var index = 0
	var prefab_count = inventory_ref.unit_presets.size()
	
	while index < prefab_count:
		var new_slot = save_slot_scene.instantiate()
		preset_dict[new_slot] = index
		new_slot.text = inventory_ref.unit_presets[index][0]
		new_slot.connect("btn_toggled", _on_preset_toggled)
		save_slot_container.add_child(new_slot)
		index += 1
	
			
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_released("cancel"):
			Messenger.ENABLE_PAUSE.emit(true)
			queue_free()

func _on_text_edit_text_changed() -> void:
	unit_name = unit_name_text_edit.text

func _on_button_pressed() -> void:
	if unit_name != null:
		inventory_ref.unit_presets.append([unit_name, gear])

func _on_preset_toggled(button, is_pressed):
	if !is_pressed:
		_on_new_preset()
	else:
		open_preset_index = preset_dict[button]
		open_preset = inventory_ref.unit_presets[open_preset_index]
		gear = open_preset[1]
		print(gear)
		
		for slot in equip_items_dict.keys():
			equip_items_dict[slot] = gear.slots[slot]
			if gear.slots[slot] != null:
				equip_dict[slot].update_contents([gear.slots[slot], 1])
		
		unit_name_text_edit.text = open_preset[0]
		unit_name = open_preset[0]
		
	
func _on_new_preset():
	gear = Gear.new()
	gear.body_type = Enums.BODY_TYPE.humanoid
	
	for slot in equip_items_dict.keys():
		equip_items_dict[slot] = null
		equip_dict[slot].clear_contents()
		
	unit_name_text_edit.text = "unit name"
	unit_name = null
	
	open_preset = null
	open_preset_index = null


'''




