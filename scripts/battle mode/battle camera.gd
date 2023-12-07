extends Node3D

const MOVE_SPEED = 5
const MOVE_MARGIN = 20
const SCROLL_BORDERS_ENABLED = false
const MIN_SELECT_RANGE = 16
const RAY_LENGTH = 1000

var start_select_pos = Vector2()

@onready var cam: Camera3D = $"Main Cam"
@onready var selection_box: Control = $"Selection Box"

func _physics_process(delta: float) -> void:	
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
	global_translate(move_vec * delta * MOVE_SPEED)

func raycast_from_mouse(m_pos, collision_mask):
	var ray_start = cam.project_ray_origin(m_pos)
	var ray_end = ray_start + cam.project_ray_normal(m_pos) * RAY_LENGTH
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end, collision_mask)
	return space_state.intersect_ray(query)

func get_entity_under_mouse(m_pos, group):
	var result = raycast_from_mouse(m_pos, 0x0002)
	if result:
		if result.collider.is_in_group(group):
			return result.collider
			
func get_entities_in_box(box_start, box_end, group):
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

func select_entities(m_pos, group, select_any_if_empty=false):
	var new_selected_dudes = []
	
	#first try to get only player entities
	if m_pos.distance_squared_to(start_select_pos) < MIN_SELECT_RANGE:
		var u = get_entity_under_mouse(m_pos, group)
		if u != null:
			new_selected_dudes.append(u)
	else:
		new_selected_dudes = get_entities_in_box(start_select_pos, m_pos, group)
		
	#if there's no player dudes in the selection try to get enemies instead
	if new_selected_dudes.size() == 0 and select_any_if_empty:
		if m_pos.distance_squared_to(start_select_pos) < MIN_SELECT_RANGE:
			var u = get_entity_under_mouse(m_pos, "entities")
			if u != null:
				new_selected_dudes.append(u)
		else:
			new_selected_dudes = get_entities_in_box(start_select_pos, m_pos, "entities")

	return new_selected_dudes
