extends Node3D

enum LOC_MODE {
	none,
	add,
	connect
}

var location_mode = LOC_MODE.none
var new_location_pos = null
var connect_from = null
const ray_length = 1000

var location_dict : Dictionary

var location_scene = preload("res://scenes/map mode/location.tscn")

@onready var cam: Camera3D = $"../Cam Base/Camera3D"

func _input(event: InputEvent) -> void:
	if Debug.enabled:
		if event is InputEventKey:
			if Input.is_action_just_released("add location"):
				location_mode = LOC_MODE.add
				Messenger.ENABLE_PAUSE.emit(false)
			elif Input.is_action_just_released("connect locations"):
				location_mode = LOC_MODE.connect
				Messenger.ENABLE_PAUSE.emit(false)
			elif Input.is_action_just_released("cancel"):
				if location_mode == LOC_MODE.connect and connect_from != null:
					connect_from.set_selected(false)
					connect_from = null
				else:
					location_mode = LOC_MODE.none
					Messenger.ENABLE_PAUSE.emit(true)
		if event is InputEventMouseButton and location_mode != LOC_MODE.none:
			if Input.is_action_just_pressed("Select"):
				match location_mode:
					LOC_MODE.add:
						var result = raycast_from_mouse(0x0004)
						if result:
							new_location_pos = result.position
					LOC_MODE.connect:
						if connect_from == null:
							var result = raycast_from_mouse(0x0002)
							if result:
								connect_from = result.collider
								connect_from.set_selected(true)
						else:
							var result = raycast_from_mouse(0x0002)
							if result:
								if !location_dict[connect_from].has(result.collider):
									location_dict[connect_from].append(result.collider)
								if !location_dict[result.collider].has(connect_from):
									location_dict[result.collider].append(connect_from)
								print(location_dict)
								Draw3D.line(connect_from.position, result.collider.position)
								connect_from.set_selected(false)
								connect_from = null
			elif Input.is_action_just_released("Select"):
				match location_mode:
					LOC_MODE.add:
						add_location()
					LOC_MODE.connect:
						pass
		if event is InputEventMouseMotion and location_mode == LOC_MODE.add:
			new_location_pos = null
			
func add_location():
	if new_location_pos != null:
		var new_location = location_scene.instantiate()
		new_location.position = new_location_pos
		location_dict[new_location] = []
		add_child(new_location)
		
func raycast_from_mouse(collision_mask):
	var m_pos = get_viewport().get_mouse_position()
	var ray_start = cam.project_ray_origin(m_pos)
	var ray_end = ray_start + cam.project_ray_normal(m_pos) * ray_length
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end, collision_mask)
	return space_state.intersect_ray(query)
		
	
