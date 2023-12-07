extends Control

var cursor_mode = Enums.CURSORMODE.default

var selected_entities = []

@onready var cam_base: Node3D = $"../Map/Controller/Cam Base"
@onready var terrain: Node3D = $"../Map/Terrain"
@onready var entities: Node3D = $"../Map/Controller/Entities"
@onready var action_bar: GridContainer = $"MarginContainer/Action Bar"

var skeleton_scene = preload("res://scenes/entity/entity scenes/skeleton.tscn")

var select_mode = Enums.SELECTMODE.default

signal something_selected(thing, is_pos)
	
func _ready() -> void:
	Messenger.connect("ENTITY_CREATED", _on_entity_created)
	Messenger.connect("ENTITY_DESTROYED", _on_entity_destroyed)
	Messenger.connect("ENTITY_SELECTED", _on_entity_selected)
	Messenger.connect("ENTITY_DESELECTED", _on_entity_deselected)	

func _on_gui_input(event: InputEvent) -> void:
	var m_pos = get_viewport().get_mouse_position()
	
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("Select", true):
			match select_mode:
				Enums.SELECTMODE.terrain_position:
					var result = cam_base.raycast_from_mouse(m_pos, 0x0004)
					if result:
						var pos = Vector3i(round(result.position.x), floor(result.position.y + 0.1), round(result.position.z))
						something_selected.emit(pos, true)
				Enums.SELECTMODE.entity_position:
					var result = cam_base.raycast_from_mouse(m_pos, 0x0002)
					if result:
						something_selected.emit(result.position, true)
				Enums.SELECTMODE.entity_collider:
					var result = cam_base.raycast_from_mouse(m_pos, 0x0002)
					if result:
						something_selected.emit(result.collider, false)
				Enums.SELECTMODE.default:
					cam_base.start_select_pos = m_pos
					cam_base.selection_box.start_pos = m_pos
					
		if Input.is_action_pressed("Select", true) and select_mode == Enums.SELECTMODE.default:
			cam_base.selection_box.m_pos = m_pos
			
		if Input.is_action_just_released("Select", true) and select_mode == Enums.SELECTMODE.default:
			var new_selected_entities = cam_base.select_entities(m_pos, "entities")
			clear_selected_entities()
			#print(selected_dudes)
			if new_selected_entities:
				for ent in new_selected_entities:
					Messenger.ENTITY_SELECTED.emit(ent)
			cam_base.selection_box.clear_vecs()
	
func _on_entity_created(entity):
	pass
	
func _on_entity_destroyed(entity):
	pass
	
func _on_entity_selected(entity):
	selected_entities.append(entity)
	entity.select()
	
func _on_entity_deselected(entity):
	entity.deselect()
	selected_entities.erase(entity)

func clear_selected_entities():
	var entities_to_deselect = selected_entities.duplicate()
	
	for ent in entities_to_deselect:
		Messenger.ENTITY_DESELECTED.emit(ent)
	
	selected_entities.clear()

func _on_player_entity_mouse_entered(entity):
	if !entity.selection.is_selected:
		match cursor_mode:
			Enums.CURSORMODE.default:
				entity.selection.set_selection_type(entity.selection.MODE.hover)
			Enums.CURSORMODE.attack:
				entity.selection.set_selection_type(entity.selection.MODE.friendly_fire)
	
func _on_player_entity_mouse_exited(entity):
	if !entity.selection.is_selected:
		entity.selection.set_selection_type(entity.selection.MODE.invisible)
	
func _on_enemy_entity_mouse_entered(entity):
	if !entity.selection.is_selected:
		match cursor_mode:
			Enums.CURSORMODE.default:
				entity.selection.set_selection_type(entity.selection.MODE.hover)
			Enums.CURSORMODE.attack:
				var in_range = action_bar.active_button.action.check_in_range(self)
				if in_range:
					entity.selection.set_selection_type(entity.selection.MODE.valid_target)
				else:
					entity.selection.set_selection_type(entity.selection.MODE.invalid_target)
	
func _on_enemy_entity_mouse_exited(entity):
	if !entity.selection.is_selected:
		entity.selection.set_selection_type(entity.selection.MODE.invisible)
