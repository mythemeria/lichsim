extends GridContainer

var action_button_scene = preload("res://scenes/GUI/action_button.tscn")
var current_entity = null
var active_button
var path

@export var skelly_data: EntityData

@onready var cursor: Control = $"../.."
@onready var terrain: Node3D = $"../../../Map/Terrain"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Messenger.connect("ENTITY_SELECTED", _on_entity_selected)
	Messenger.connect("ENTITY_DESELECTED", _on_entity_deselected)
	Messenger.connect("TURN_ENDED", _on_turn_ended)
	Messenger.connect("TURN_STARTED", _on_turn_started)
	
	
func _on_entity_selected(entity):
	'''if active_button != null:
		var args = get_action_args(false, entity)	
					
		print(active_button.action.do_action(args))'''
	pass

func _on_entity_deselected(_entity):
	pass
	
func _on_turn_ended(_entity):
	for child in get_children():
		child.queue_free()

func _on_turn_started(entity):
	if entity.entity_type == Enums.ENTITY_TYPE.player and entity.equip_data != null:
		for action in entity.equip_data.actions:
			var new_action = action_button_scene.instantiate()
			new_action.text = action.action_name
			new_action.action = action
			add_child(new_action)
			new_action.action_toggled.connect(_on_action_toggled)
			
func _on_action_toggled(button_pressed, button):
	#reset the previous button
	if active_button != null:
		active_button.set_pressed_no_signal(false)
		active_button = null
	
	#set the new button
	if button_pressed:
		active_button = button
		cursor.select_mode = active_button.action.select_mode
		#cursor.set_actions(Enums.CURSORMODE.default)
	else:
		cursor.select_mode = Enums.SELECTMODE.default
		#cursor.set_actions(Enums.CURSORMODE.default)


#thing is either a vec3 position or an entity
func _on_gui_something_selected(position_or_target, is_position) -> void:
	if active_button != null:
		var args : Array
		for argument in active_button.action.required_arguments:
			match argument:
				#position
				0:
					if !is_position:
						print("there shouldnt be a position here?")
					else:
						args.append(position_or_target)
				#target entity
				1:
					if is_position:
						print("asking for a target entity for something that doesn't provide one")
					else:
						args.append(position_or_target)
				#self action
				2:
					args.append(active_button.action)
				#entity_data
				3:
					args.append(skelly_data)

		active_button.action.do_action(args, current_entity)
