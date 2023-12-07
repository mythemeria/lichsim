extends Node3D

@export var enemy_party_data : Resource
@export var player_party_data : Resource

@onready var cursor: Control = $"../../../GUI"
@onready var terrain: Node3D = $"../../Terrain"
@onready var spawners: Node3D = $"../Spawners"
@onready var turn_engine: ScrollContainer = $"../../../GUI/MarginContainer/turn profiles"


var enemy_spawn_positions : Array
var player_spawn_positions : Array
var environment_spawn_positions : Array

signal parties_loaded()

func _ready() -> void:
	Messenger.connect("ENTITY_CREATED", _on_entity_created)
	
	for child in spawners.get_children():
		var arr
		match child.entity_type:
			Enums.ENTITY_TYPE.player:
				arr = player_spawn_positions
			Enums.ENTITY_TYPE.enemy:
				arr = enemy_spawn_positions
			Enums.ENTITY_TYPE.environment:
				arr = environment_spawn_positions
				
		arr.append(Vector3i(child.position))	
				
	enemy_spawn_positions.shuffle()
	player_spawn_positions.shuffle()
	environment_spawn_positions.shuffle()
	
	for party_member in enemy_party_data.party_members:
		if !enemy_spawn_positions.is_empty():
			var pos = enemy_spawn_positions.pop_back()
			
			summon_entity(pos, party_member)
		
	for party_member in player_party_data.party_members:
		if !player_spawn_positions.is_empty():
			var pos = player_spawn_positions.pop_back()
			
			summon_entity(pos, party_member)
			
	parties_loaded.emit()

func summon_entity(pos, entity_data):
	#first check if theres a guy already there
	if !terrain.check_traversible(pos):
		return false
		
	var entity_scene = entity_data.scene
	var new_entity = entity_scene.instantiate()
	new_entity.position = pos
	
	add_child(new_entity)
	
	if entity_data.override_gear:
		new_entity.equip_data.replace_gear(entity_data.gear)
		
		if !entity_data.additional_actions.is_empty():
			for additional_action in entity_data.additional_actions:
				new_entity.equip_data.add_action(additional_action)
		
	if entity_data.override_stats:
		new_entity.max_hp = entity_data.max_hp
		new_entity.strength = entity_data.strength
		new_entity.magic = entity_data.magic
		new_entity.max_move = entity_data.max_move
		new_entity.move_speed = entity_data.move_speed
		
	if entity_data.override_avatar:
		new_entity.avatar = entity_data.avatar
		
	for action in new_entity.equip_data.actions:
		action.set_function_parent(cursor, terrain, self, turn_engine)
			
	return true
	
func _on_entity_created(entity):
	match entity.entity_type:
		Enums.ENTITY_TYPE.player:
			entity.connect("entity_mouse_entered", cursor._on_player_entity_mouse_entered)
			entity.connect("entity_mouse_exited", cursor._on_player_entity_mouse_exited)
		Enums.ENTITY_TYPE.enemy:
			entity.connect("entity_mouse_entered", cursor._on_enemy_entity_mouse_entered)
			entity.connect("entity_mouse_exited", cursor._on_enemy_entity_mouse_exited)
