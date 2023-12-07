extends Node3D

@onready var entities: Node3D = $Entities
@onready var cam: Camera3D = $"Cam Base/Main Cam"
#@onready var selection_box: Control = $"Cam Base/Selection Box"

var skeleton = preload("res://scenes/skelly/skeleton.tscn")
var dudes_array = Array()
var selected_dudes = Array()
var occupied_positions = Array()

#var start_select_pos = Vector2()

'''const MOVE_SPEED = 5
const MOVE_MARGIN = 20
const SCROLL_BORDERS_ENABLED = false'''
#const MIN_SELECT_RANGE = 16

#const ray_length = 1000

#signals
signal find_path(start, end)
#signal attack_target(target)
#signal find_destinations(pos, max_move)

func _ready() -> void:
	Messenger.connect("ENTITY_CREATED", _on_entity_created)
	Messenger.connect("ENTITY_DESTROYED", _on_entity_destroyed)
	Messenger.connect("ENTITY_SELECTED", _on_entity_selected)
	Messenger.connect("ENTITY_DESELECTED", _on_entity_deselected)
	
	#summon ur lich guy
	summon_dude(Vector3(0, 1, 0))

'''func _physics_process(delta: float) -> void:	
	var m_pos = get_viewport().get_mouse_position()
	#move the camera position
	calc_move(m_pos, delta)
	
func calc_move(m_pos, delta):
	var v_size = get_viewport().size
	var move_vec = Vector3()
	
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		move_vec.x = direction.x
		move_vec.z = direction.z
	elif SCROLL_BORDERS_ENABLED:
		if m_pos.x < MOVE_MARGIN:
			move_vec.x -= 1
		if m_pos.y < MOVE_MARGIN:
			move_vec.z -= 1
		if m_pos.x > v_size.x - MOVE_MARGIN:
			move_vec.x += 1
		if m_pos.y > v_size.y - MOVE_MARGIN:
			move_vec.z += 1
		move_vec = (transform.basis * Vector3(move_vec.x, 0, move_vec.z)).normalized()
	
	move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation_degrees.y)
	cam.global_translate(move_vec * delta * MOVE_SPEED)'''
	#health_bars.position.x += move_vec.x * delta * MOVE_SPEED
	
'''func raycast_from_mouse(m_pos, collision_mask):
	var ray_start = cam.project_ray_origin(m_pos)
	var ray_end = ray_start + cam.project_ray_normal(m_pos) * ray_length
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end, collision_mask)
	return space_state.intersect_ray(query)'''

func select_dudes(m_pos):
	var new_selected_dudes = []
	
	#first try to get only player entities
	if m_pos.distance_squared_to(start_select_pos) < MIN_SELECT_RANGE:
		var u = get_dude_under_mouse(m_pos, "dudes")
		if u != null:
			new_selected_dudes.append(u)
	else:
		new_selected_dudes = get_dudes_in_box(start_select_pos, m_pos, "dudes")
		
	#if there's no player dudes in the selection try to get enemies instead
	if new_selected_dudes.size() == 0:
		if m_pos.distance_squared_to(start_select_pos) < MIN_SELECT_RANGE:
			var u = get_dude_under_mouse(m_pos, "enemies")
			if u != null:
				new_selected_dudes.append(u)
		else:
			new_selected_dudes = get_dudes_in_box(start_select_pos, m_pos, "enemies")

	return new_selected_dudes

'''func get_dudes_in_box(box_start, box_end, group):
	var x0 = min(box_start.x, box_end.x)
	var y0 = min(box_start.y, box_end.y)
	var x1 = max(box_start.x, box_end.x)
	var y1 = max(box_start.y, box_end.y)
	var box = Rect2(x0, y0, x1-x0, y1-y0)
	var box_selected_dudes = []
	for dude in get_tree().get_nodes_in_group(group):
		if box.has_point(cam.unproject_position(dude.global_transform.origin)):
			box_selected_dudes.append(dude)
	return box_selected_dudes

func get_dude_under_mouse(m_pos, group):
	var result = raycast_from_mouse(m_pos, 0x0002)
	if result:
		if result.collider.is_in_group(group):
			return result.collider'''

#emited signals
func clear_selected_dudes():
	var dudes_to_deselect = []
	for dude in selected_dudes:
		dudes_to_deselect.append(dude)
	
	for dude in dudes_to_deselect:
		Messenger.ENTITY_DESELECTED.emit(dude)
	
	selected_dudes.clear()
	
func summon_dude(pos):
	pos.y += 0.1
	pos = Vector3(round(pos.x), floor(pos.y), round(pos.z))
	#first check if theres a guy already there
	if occupied_positions.has(pos):
		return false
	
	var new_dude = skeleton.instantiate()
	new_dude.position = pos
	entities.add_child(new_dude)
	dudes_array.append(new_dude)
	occupied_positions.append(pos)
	return true
	
#this could also be possibly broken but it's untested so I don't know
func dismiss_dude(dude):
	selected_dudes.erase(dude)
	dudes_array.erase(dude)
	dude.die()

func _on_terrain_path_found(path) -> void:
	if selected_dudes.size() != 1:
		return
	
	var dude = selected_dudes[0]
	print("moving")
	dude.move(path)

func _on_entity_created(_entity):
	pass
	
func _on_entity_destroyed(_entity):
	pass
	
func _on_entity_selected(entity):
	selected_dudes.append(entity)
	entity.select()
	
func _on_entity_deselected(entity):
	entity.deselect()
	selected_dudes.erase(entity)


'''func _on_gui_gui_input(event: InputEvent) -> void:
	var m_pos = get_viewport().get_mouse_position()
	
	if event is InputEventMouseButton:
		Cursor.do_action(event, m_pos)
		
		
	
	if Input.is_action_just_pressed("Select"):
		match Cursor.cursor_mode:
			Cursor.CURSORMODE.default:
				start_select_pos = m_pos
				selection_box.start_pos = m_pos
			Cursor.CURSORMODE.summon:
				var result = raycast_from_mouse(m_pos, 0x0004)
				#only summon a guy if you clicked the terrain
				if result:
					summon_dude(result.position)
			Cursor.CURSORMODE.move:
				if selected_dudes.size() == 1:
					var result = raycast_from_mouse(m_pos, 0x0004)
					if result:
						var endpos = Vector3i(round(result.position.x), floor(result.position.y+0.1), round(result.position.z))
						find_path.emit(Vector3i(selected_dudes[0].position), endpos)
			Cursor.CURSORMODE.attack:
				var result = raycast_from_mouse(m_pos, 0x0002)
				if result:
					attack_target.emit(result.collider)
				''''''
				if selected_dudes.size() == 1:
					var result = raycast_from_mouse(m_pos, 0x0002)
					if result:
						if result.collider != selected_dudes[0]:
							selected_dudes[0].attack(result.collider)''''''
				
	if Input.is_action_pressed("Select"):
		match Cursor.cursor_mode:
			Cursor.CURSORMODE.default:
				selection_box.m_pos = m_pos
			Cursor.CURSORMODE.summon:
				pass
			Cursor.CURSORMODE.move:
				pass
	
	if Input.is_action_just_released("Select"):
		match Cursor.cursor_mode:
			Cursor.CURSORMODE.default:
				var new_selected_dudes = select_dudes(m_pos)
				clear_selected_dudes()
				#print(selected_dudes)
				if new_selected_dudes:
					for dude in new_selected_dudes:
						Messenger.ENTITY_SELECTED.emit(dude)
				selection_box.clear_vecs()
			Cursor.CURSORMODE.summon:
				pass
			Cursor.CURSORMODE.move:
				pass'''
