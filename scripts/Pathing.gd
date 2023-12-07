extends Node3D

@onready var grid_map: GridMap = $GridMap

var visual_node = preload("res://scenes/graph_node_visual.tscn")

var graph = {}
var ground_dict = {}
var air_dict = {}
var levels = []
var intraversible_entities = []

var open_nodes = []
var closed_nodes = []
var path_to = {}
var hcosts = {}
var gcosts = {}
var fcosts = {}

var astar_timeout = 3000
var max_fall_distance = 3
var fall_edge_weight = 1.5
var climb_edge_weight = 1.5
var diagonal_edge_weight = 1.5

var debug_visualisation_enabled = false
var dots_array = []

signal path_found(path: Array)

func check_diagonal(pos, direction1, direction2):
	#see if the diagonal pos is valid
	if (!air_dict.has(pos + direction1 + direction2)
	or !ground_dict.has(pos + direction1 + direction2 + Vector3i.DOWN)):
		return false
	elif (!air_dict[pos + direction1 + direction2]
	or !ground_dict[pos + direction1 + direction2 + Vector3i.DOWN]):
		return false
	if (air_dict.has(pos + direction1)
	and air_dict.has(pos + direction2)
	and ground_dict.has(pos + direction1 + Vector3i.DOWN)
	and ground_dict.has(pos + direction2 + Vector3i.DOWN)):
		if (air_dict[pos + direction1]
		and air_dict[pos + direction2]
		and ground_dict[pos + direction1 + Vector3i.DOWN]
		and ground_dict[pos + direction2 + Vector3i.DOWN]):
			return true

func check_direction(pos, direction):
	var valid = []
	if air_dict.has(pos + direction):
		if air_dict[pos + direction]:
			if ground_dict[pos + direction + Vector3i.DOWN]:
				valid.append([pos + direction, 1])
			else:
				var new = check_fallable(pos + direction)
				if new:
					valid.append(new)
		else:
			var new = check_climbable(pos + direction)
			if new:
				valid.append([new, climb_edge_weight])
	return valid

func check_neighbours(pos):
	pos+=Vector3i.UP
	var valid_neighbours = []
	valid_neighbours.append_array(check_direction(pos, Vector3i.RIGHT))
	valid_neighbours.append_array(check_direction(pos, Vector3i.LEFT))
	valid_neighbours.append_array(check_direction(pos, Vector3i.BACK))
	valid_neighbours.append_array(check_direction(pos, Vector3i.FORWARD))
	if check_diagonal(pos, Vector3i.LEFT, Vector3i.BACK):
		valid_neighbours.append([pos + Vector3i.LEFT + Vector3i.BACK, diagonal_edge_weight])
	if check_diagonal(pos, Vector3i.RIGHT, Vector3i.BACK):
		valid_neighbours.append([pos + Vector3i.RIGHT + Vector3i.BACK, diagonal_edge_weight])
	if check_diagonal(pos, Vector3i.LEFT, Vector3i.FORWARD):
		valid_neighbours.append([pos + Vector3i.LEFT + Vector3i.FORWARD, diagonal_edge_weight])
	if check_diagonal(pos, Vector3i.RIGHT, Vector3i.FORWARD):
		valid_neighbours.append([pos + Vector3i.RIGHT + Vector3i.FORWARD, diagonal_edge_weight])
		
	return valid_neighbours

func check_climbable(pos):
	var above_block = pos + Vector3i.UP	
	if ground_dict.has(pos):
		if ground_dict[pos]:
			return above_block
	else:
		return false

func check_fallable(pos):
	for dist in range(0, max_fall_distance+2): 
		var below_block = pos + (Vector3i.DOWN * dist)
		if ground_dict.has(below_block):
			if ground_dict[below_block]:
				return [below_block + Vector3i.UP, dist * fall_edge_weight]
	return false
	
# Called when the node enters the scene tree for the first time.
func _ready():
	Messenger.connect("ENTITY_CREATED", add_entity)
	Messenger.connect("ENTITY_MOVED", move_entity)
	Messenger.connect("ENTITY_DESTROYED", remove_entity)
	
	var used_nodes = grid_map.get_used_cells()
	
	var x_min = 0
	var z_min = 0
	var x_max = 0
	var z_max = 0
	var y_max = 0
	for node in used_nodes:
		if node.y > y_max:
			y_max = node.y
		if node.x > x_max:
			x_max = node.x
		if node.x < x_min:
			x_min = node.x
		if node.z > z_max:
			z_max = node.z
		if node.z < z_min:
			z_min = node.z
	
	
	for n in range(0, y_max+1):
		levels.append([])
	
	#adding an extra level to deal with possible index out of bounds bs
	levels.append([])
	
	for node in used_nodes:
		levels[node.y].append(node)
	
	#fill the on ground dict with bools corresponding to whether that position is air above ground
	for y in range(0, y_max+1):
		var curr_level = levels[y]
		var above_level = levels[y+1]
		for x in range(x_min, x_max+1):
			for z in range(z_min, z_max+1):
				var is_ground = false
				var is_air = true
				var key = Vector3i(x, y, z)
				if curr_level.has(key) and !above_level.has(Vector3i(x,y+1,z)):
					is_ground = true
				ground_dict[key] = is_ground
				if above_level.has(key+Vector3i.UP):
					is_air = false
				air_dict[key+Vector3i.UP] = is_air

	# use that dict to generate the graph
	for y in range(0, y_max+1):
		#var curr_level = levels[y]
		#var above_level = levels[y+1]
		for x in range(x_min, x_max+1):
			for z in range(z_min, z_max+1):
				var pos = Vector3i(x, y, z)
				if ground_dict[pos]:
					var neighbour_array = check_neighbours(pos)
					if !neighbour_array.is_empty():
						graph[pos+Vector3i.UP] = neighbour_array

	if debug_visualisation_enabled:
		for node in graph.keys():
			var new_node = visual_node.instantiate()
			new_node.position = Vector3(node.x, node.y, node.z) + Vector3(0.5,0.7,0.5)
			grid_map.add_child(new_node)
	

	#print(graph)
	#find_astar_path(Vector3i(7, 1, -6), Vector3i(4, 1, 6))
	
	
func get_true_distance_between_points(pos1, pos2):
	return (pos1-pos2).length()
	
func calculate_neighbour_costs(pos, end_pos):
	if graph.has(pos):
		for neighbour in graph[pos]:
			var vec = neighbour[0]
			if vec == end_pos:
				path_to[vec] = pos
				return true
			if !closed_nodes.has(vec) and !intraversible_entities.has(vec):
				if open_nodes.has(vec):
					if fcosts[vec] > hcosts[pos] + neighbour[1] + get_true_distance_between_points(vec, end_pos):
						gcosts[vec] = hcosts[pos] + neighbour[1]
						hcosts[vec] = get_true_distance_between_points(vec, end_pos)
						fcosts[vec] = gcosts[vec] + hcosts[vec]
						path_to[vec] = pos
				else:
					gcosts[vec] = hcosts[pos] + neighbour[1]
					hcosts[vec] = get_true_distance_between_points(vec, end_pos)
					fcosts[vec] = gcosts[vec] + hcosts[vec]
					open_nodes.append(vec)
					path_to[vec] = pos
	return false
	
func find_astar_path(start_pos, end_pos):
	open_nodes = []
	closed_nodes = []
	path_to = {}
	hcosts = {}
	gcosts = {}
	fcosts = {}
	
	for dot in dots_array:
		dot.queue_free()
	dots_array.clear()
	
	#first check the nodes are actually in the graph lmao
	if !graph.has(start_pos) or !graph.has(end_pos) or intraversible_entities.has(end_pos):
		print("cant find path: one of the positions is not in the graph")
		return false
	
	var init_hcost = get_true_distance_between_points(start_pos, end_pos)
	gcosts[start_pos] = 0
	hcosts[start_pos] = init_hcost
	fcosts[start_pos] = gcosts[start_pos] + hcosts[start_pos]
	closed_nodes.append_array(intraversible_entities)
	var found = calculate_neighbour_costs(start_pos, end_pos)
	
	var repeat_count = 0
	while !found and repeat_count <= astar_timeout:
		var min_fcost = 99999999
		for node in open_nodes:
			var fcost = fcosts[node]
			min_fcost = min(fcost, min_fcost)
			
		var candidates = []
		var candidate_hcost = []
		for node in open_nodes:
			if fcosts[node] == min_fcost:
				candidates.append(node)
				candidate_hcost.append(hcosts[node])
		
		var hcost_min = candidate_hcost.min()
		var go_forth
		for node in candidates:
			if hcost_min == hcosts[node]:
				go_forth = node
		
		#close the node if it isn't already
		if !closed_nodes.has(go_forth):
			closed_nodes.append(go_forth)
			open_nodes.erase(go_forth)
		found = calculate_neighbour_costs(go_forth, end_pos)
		
		repeat_count += 1
	
	if found:
		var path = []
		var curr_node = end_pos
		path.append(curr_node)
		while curr_node != start_pos:
			path.append(path_to[curr_node])
			curr_node = path_to[curr_node]
		
		path.reverse()
		path.erase(curr_node)
		
		path_found.emit(path)

	
func add_entity(ent):
	intraversible_entities.append(Vector3i(ent.position.x, ent.position.y, ent.position.z))
	
func move_entity(init_pos, curr_pos):
	intraversible_entities.erase(init_pos)
	intraversible_entities.append(curr_pos)
	
func remove_entity(ent):
	intraversible_entities.erase(Vector3i(ent.position.x, ent.position.y, ent.position.z))
	
func check_traversible(pos):
	if intraversible_entities.has(pos):
		return false
		
	if graph.keys().has(pos):
		return true
	else:
		print(graph.keys())
		return false
	
	
	
	
	
	
#many hours were wasted here do not keep working on it
'''func get_valid_destinations(pos, max_distance):
	var destinations = []
	var queue = [[pos, 0]]
	var closed_nodes = []
	
	while queue:
		var node = queue.pop_front()
		if !closed_nodes.has(node[0]):
			closed_nodes.append(node[0])
			if node[1] <= max_distance:
				for neighbour in graph[node]:
					queue.append([neighbour[0], node[1] + 1])
		print(queue)
					
				
	destinations = closed_nodes

	#get rid of any invalid nodes
	for node in destinations:
		if intraversible_entities.has(node):
			#print(node)
			destinations.erase(node)
	
	#debug shit
	for node in destinations:
		var new_node = visual_node.instantiate()
		new_node.position = Vector3(node.x, node.y, node.z) + Vector3(0.5,0.7,0.5)
		add_child(new_node)

	return destinations
	
func try_neighbours(pos, dist, max_distance, destinations, closed):
	if dist <= max_distance:
		for neighbour in graph[pos]:
			var vec = neighbour[0]
			try_neighbours(vec, dist + 1, max_distance, destinations, closed)
	closed.append(pos)
	
	for node in graph[pos]:
		if dist <= max_distance:
			if !destinations.has(node[0]):
				destinations.append(node[0])
			if !closed.has(node[0]):
				try_neighbours(node[0], dist + 1, max_distance, destinations, closed)
	closed.append(pos)

func _on_controller_find_destinations(pos, max_move) -> void:
	get_valid_destinations(pos, max_move)'''


func _on_gui_find_path(start, end) -> void:
	find_astar_path(start, end)
