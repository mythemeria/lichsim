extends Control

var contents : Array = [null, 0]
var x_offset = 0
var y_offset = 0

@onready var icon: TextureRect = $TextureRect
@onready var label: Label = $Label

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		position.x = event.position.x - x_offset
		position.y = event.position.y - y_offset
			
	
func add_item(item_data, mx_offset, my_offset):
	x_offset = mx_offset
	y_offset = my_offset
	position.x -= x_offset
	position.y -= y_offset
	contents = item_data
	update_display()
	
func remove_item():
	var tmp = contents
	contents = [null, 0]
	update_display()
	x_offset = 0
	y_offset = 0
	return tmp
	
func update_display():
	if !is_empty():
		icon.texture = contents[0].icon
		if !contents[0].stackable:
			label.text = ""
		else:
			label.text = str(contents[1])
	else:
		icon.texture = null
		label.text = ""
	
func update_contents(new_contents):
	contents = new_contents
	update_display()

func increment_count(increment):
	if contents[0].stackable:
		contents[1] += increment
		update_display()
	
func is_empty():
	return (contents == [null, 0])
