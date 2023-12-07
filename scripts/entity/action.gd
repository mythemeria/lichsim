extends Resource
class_name Action

enum arguments_dict {
	position,
	target_entity,
	self_action,
	entity_data,
	self_entity
}

@export var action_name: String
@export var action_range = 0
@export var cursor_mode : Enums.CURSORMODE
@export var select_mode : Enums.SELECTMODE
@export_enum("arc", "pathed", "ray") var range_type
@export var icon: Texture2D
@export var called_function : String
@export_enum("cursor", "terrain", "party controller", "action", "turn engine") var function_parent_id
@export var required_arguments : Array[arguments_dict]

var target_in_range = false
var function_parent : Object = null
	
func check_in_range(_target):
	return
	
func check_initialised():
	return !function_parent == null
	
func do_action(args, ent):
	if check_initialised():
		if required_arguments.has(arguments_dict.self_entity):
			args.append(ent)
		var callable = Callable(function_parent, called_function)
		callable.callv(args)
		return true
	else:
		return false

func set_function_parent(cursor, terrain, party_controller, turn_engine):
	match function_parent_id:
		#cursor
		0:
			function_parent = cursor
		#terrain
		1:
			function_parent = terrain
		#party controller
		2:
			function_parent = party_controller
		#action
		3:
			function_parent = self
		#turn engine
		4:
			function_parent = turn_engine
