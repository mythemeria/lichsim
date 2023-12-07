extends ScrollContainer

#ordered array of the turn order. first in the array goes first
var turn_order = []
var current_turn_index = 0
var no_turns_taken = true
var selected_profiles = []

var moving_entity = null

var profile_dict = {}

var profile_scene = preload("res://scenes/GUI/turn profile.tscn")

@onready var container: HBoxContainer = $HBoxContainer
@onready var action_bar: GridContainer = $"../Action Bar"
@onready var terrain: Node3D = $"../../../Map/Terrain"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Messenger.connect("ENTITY_CREATED", _on_entity_created)
	Messenger.connect("ENTITY_DESTROYED", _on_entity_destroyed)
	Messenger.connect("ENTITY_SELECTED", _on_entity_selected)
	Messenger.connect("ENTITY_DESELECTED", _on_entity_deselected)
	
func _on_entity_created(entity):
	if !turn_order.has(entity) and entity.entity_type != Enums.ENTITY_TYPE.environment:
		var active_entity = null
		if turn_order.size() > 0:
			active_entity = turn_order[current_turn_index]
		var initiative = entity.initiative
		var insertion_index = 0
		
		for index in range(0, turn_order.size()):
			if initiative <= turn_order[index].initiative:
				insertion_index = index + 1
			else:
				break
		
		turn_order.insert(insertion_index, entity)
		var new_profile = profile_scene.instantiate()
		new_profile.icon = entity.avatar
		new_profile.associated_entity = entity
		container.add_child(new_profile)
		new_profile.set_profile_active(false)
		profile_dict[entity] = new_profile
		new_profile.connect("profile_selected", _on_profile_selected)
		
		var index = 0
		for ent in turn_order:
			container.move_child(profile_dict[ent], index)
			index += 1
			
		if active_entity != null:
			current_turn_index = turn_order.find(active_entity)
			
		Messenger.TURN_ORDER_ENTERED.emit(entity, insertion_index)
	else:
		print("for some reason you attempted an entity that was already in the turn order to the turn order")
	
func _on_entity_destroyed(entity):
	if turn_order.has(entity):
		Messenger.TURN_ORDER_LEFT.emit(entity)
		turn_order.erase(entity)
		profile_dict[entity].queue_free()
		profile_dict.erase(entity)
		if current_turn_index >= turn_order.size():
			current_turn_index = 0
	else:
		print("tried to remove entity from turn order who wasn't in it")
		
func next_turn():
	#end the current entities turn
	var entity = turn_order[current_turn_index]
	entity.turn_active = false
	profile_dict[entity].set_profile_active(false)
	Messenger.TURN_ENDED.emit(entity)
	
	#move to the next entity in the turn order
	current_turn_index += 1
	if current_turn_index >= turn_order.size():
		current_turn_index = 0
	
	#start the next entity's turn
	entity = turn_order[current_turn_index]
	entity.turn_active = true
	profile_dict[entity].set_profile_active(true)
	
	Messenger.TURN_STARTED.emit(entity)
	for profile in selected_profiles:
		Messenger.ENTITY_DESELECTED.emit(profile.associated_entity)
	Messenger.ENTITY_SELECTED.emit(entity)

	#print(entity.initiative)

#region signals
func _on_end_turn_pressed() -> void:
	next_turn()
	
func _on_entity_selected(entity):
	var selected_profile = profile_dict[entity]
	selected_profiles.append(selected_profile)
	selected_profile.button_pressed = true
	
	
func _on_entity_deselected(entity):
	var profile = profile_dict[entity]
	selected_profiles.erase(profile)
	profile.button_pressed = false

func _on_profile_selected(profile):
	var temp_selected_profiles = selected_profiles.duplicate()
	for prof in temp_selected_profiles:
		Messenger.ENTITY_DESELECTED.emit(prof.associated_entity)
	Messenger.ENTITY_SELECTED.emit(profile.associated_entity)

func _on_terrain_path_found(path) -> void:
	if moving_entity != null:
		moving_entity.move(path)
		moving_entity = null
	else:
		print("trying to move but there is no moving entity set?")

func move_active_entity(pos):
	moving_entity = turn_order[current_turn_index]
	terrain.find_astar_path(Vector3i(moving_entity.position), Vector3i(pos))

func attack(target, action):
	var entity = turn_order[current_turn_index]
	entity.attack(target, action)


func _on_entities_parties_loaded() -> void:
	current_turn_index = 0
	var entity = turn_order[current_turn_index]
	entity.turn_active = true
	profile_dict[entity].set_profile_active(true)
	Messenger.TURN_STARTED.emit(entity)
