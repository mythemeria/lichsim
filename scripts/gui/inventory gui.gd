extends Control

var item_count
var columns = 8
var max_rows_visible = 9
var scrollbar_width = 15
var box_separation = 4

var box_width = 40
var box_height = 40

#this is set separately from the margins on the margin container so if you change it you need to update both
var margin = 16

var inventory_ref

var item_box_scene = preload("res://scenes/GUI/inventory/item box 2.tscn")
var box_array : Array[Button]
var box_dict : Dictionary

var hovered_box

@onready var panel: Panel = $CenterContainer/Panel
@onready var grid: GridContainer = $CenterContainer/Panel/MarginContainer/ScrollContainer/GridContainer
@onready var cursor_inventory: Control = $"Cursor Inventory"

var debug_slot_scene = preload("res://scenes/GUI/debug/toomanyitems icon.tscn")
var debug_slots : Array
@onready var debug_margin_container: MarginContainer = $MarginContainer
@onready var debug_grid_container: GridContainer = $MarginContainer/ScrollContainer/GridContainer



func _ready() -> void:
	Messenger.ENABLE_PAUSE.emit(false)
	inventory_ref = SaveInfo.loaded_game_data.inventory
	var rows = max(max_rows_visible, ceil(inventory_ref.inv_slot_data.size()/columns))
	
	panel.custom_minimum_size.x = (columns * box_width) + (box_separation * (columns - 1)) + scrollbar_width + (margin * 2)
	panel.custom_minimum_size.y = (box_height * max_rows_visible) + (box_separation * (max_rows_visible - 1)) + (margin * 2)
	
	var index = 0
	while index < rows * columns:
		var new_item_box = item_box_scene.instantiate()
		new_item_box.size.x = box_width
		new_item_box.size.y = box_height
		if inventory_ref.inv_slot_data.size() <= index:
			inventory_ref.inv_slot_data.append([null, 0])
		new_item_box.contents = inventory_ref.inv_slot_data[index]
		box_dict[new_item_box] = index
		new_item_box.connect("box_input_event", _on_box_input)
		new_item_box.connect("box_mouse_entered", _on_box_mouse_entered)
		grid.add_child(new_item_box)
		index += 1
		
	if !Debug.enabled:
		debug_margin_container.queue_free()
	else:
		for item in ResourceManager.items:
			var new_slot = debug_slot_scene.instantiate()
			debug_slots.append(new_slot)
			new_slot.contents = item
			new_slot.connect("box_clicked", _on_debug_input)
			debug_grid_container.add_child(new_slot)
			
	Messenger.connect("INVENTORY_UPDATED", _on_inventory_updated)

	
func _on_inventory_updated():
	for box in box_dict.keys:
		if inventory_ref.inv_slot_data[box_dict[box]] != box.contents:
			box.contents = inventory_ref.inv_slot_data[box_dict[box]]
			box.update_display()

func _on_box_mouse_entered(box):
	hovered_box = box


func _on_box_input(box, event):
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("Select"):
			var cursor_pos = get_global_mouse_position()
			var item_pos = box.get_screen_position()
			var offset_x = cursor_pos.x - item_pos.x
			var offset_y = cursor_pos.y - item_pos.y
			if cursor_inventory.is_empty():
				cursor_inventory.add_item(box.clear_contents(), offset_x, offset_y)
		elif Input.is_action_just_released("Select"):
			if hovered_box != null:
				if hovered_box.contents == [null, 0]:
					var new_contents = cursor_inventory.remove_item()
					hovered_box.update_contents(new_contents)
					inventory_ref.inv_slot_data[box_dict[hovered_box]] = new_contents
					inventory_ref.inv_slot_data[box_dict[box]] = [null, 0]
				elif hovered_box.contents != [null, 0] and hovered_box.contents[0].stackable:
					var tmp = cursor_inventory.remove_item()
					var new_contents = [tmp[0], hovered_box.contents[1] + tmp[1]]
					hovered_box.update_contents(new_contents)
					inventory_ref.inv_slot_data[box_dict[hovered_box]] = new_contents
					inventory_ref.inv_slot_data[box_dict[box]] = [null, 0]			
				else:
					box.update_contents(cursor_inventory.remove_item())
			else:
				box.update_contents(cursor_inventory.remove_item())


func _on_debug_input(slot, event):
	if event is InputEventMouseButton:
		var cursor_pos = get_global_mouse_position()
		var item_pos = slot.get_screen_position()
		var offset_x = cursor_pos.x - item_pos.x
		var offset_y = cursor_pos.y - item_pos.y
		if Input.is_action_just_pressed("Select", true):
			cursor_inventory.add_item([slot.contents, 1], offset_x, offset_y)
		elif Input.is_action_just_pressed("right click", true):
			if slot.contents == cursor_inventory.contents[0]:
				cursor_inventory.increment_count(1)
		elif Input.is_action_just_released("Select"):
			if hovered_box != null:
				if hovered_box.contents == [null, 0]:
					var new_contents = cursor_inventory.remove_item()
					hovered_box.update_contents(new_contents)
					inventory_ref.inv_slot_data[box_dict[hovered_box]] = new_contents
				elif hovered_box.contents != [null, 0] and hovered_box.contents[0].stackable:
					var tmp = cursor_inventory.remove_item()
					var new_contents = [tmp[0], hovered_box.contents[1] + tmp[1]]
					hovered_box.update_contents(new_contents)
					inventory_ref.inv_slot_data[box_dict[hovered_box]] = new_contents
				else:
					cursor_inventory.remove_item()		
			else:
				cursor_inventory.remove_item()


func _on_panel_mouse_exited() -> void:
	hovered_box = null

			
