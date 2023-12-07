extends CharacterBody3D
class_name Entity

var selection: Node3D
var health: Node
@export var equip_data : Node = null
var initiative = 0
var turn_active = false

@export var max_hp = 0
@export var strength = 0
@export var magic = 0
@export var max_move = 0
@export var move_speed = 0

#settings you can set in the editor for simplicity in entity creation
@export var affected_by_gravity = false
@export var is_selectable = false
##adds a health component
@export var has_health = false
@export var has_health_bar = false
@export var intraversible = false
@export var body_type: Enums.BODY_TYPE
@export var entity_type: Enums.ENTITY_TYPE
@export var avatar: Texture2D

signal entity_mouse_entered(entity)
signal entity_mouse_exited(entity)

#references to scenes for instantiation
var health_scene = preload("res://scenes/entity/health.tscn")
var selection_scene = preload("res://scenes/entity/selection.tscn")
var equip_data_scene = preload("res://scenes/entity/equip data.tscn")

var entity_id = 0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

#movement shit
var path = []
var path_index = 0
var t = 0

func _ready() -> void:
	roll_initiative()
	
	#add selection component
	if is_selectable:
		selection = selection_scene.instantiate()
		self.add_child(selection)
	
	#add health component
	if has_health:
		if max_hp <= 0:
			print("one of your entities has health but you haven't set the max_hp. health has not been set")
		else:
			health = health_scene.instantiate()
			health.set_max_health(max_hp)
			self.add_child(health)
			if has_health_bar:
				health.add_health_bar()		
	
	#add the ability to equip items	but only if we didn't add a gear node manually
	if equip_data == null:
		equip_data = equip_data_scene.instantiate()
		add_child(equip_data)
		equip_data.gear.body_type = body_type
	
	#finally, tell everyone else that a new entity was created	
	Messenger.ENTITY_CREATED.emit(self)

func _physics_process(delta: float) -> void:
	if affected_by_gravity and not is_on_floor():
		velocity.x = 0
		velocity.z = 0
		velocity.y -= gravity * delta
		
	#should probably check if the character can move in the first place
	#but path shouldnt even be set if it can't
	#btw we are literally just teleporting the entity to the next position atm
	#need to add tweens later
	if path and path_index <= max_move:
		t += delta * move_speed
		if t >= 1:
			Messenger.ENTITY_MOVED.emit(Vector3i(position), Vector3i(path[path_index]))
			position = path[path_index]
			path_index += 1
			t = 0
			if path.size() == path_index:
				path = []
				path_index = 0
	elif path_index > max_move:
		path = []
		path_index = 0
	
	move_and_slide()

func take_damage(damage):
	if health:
		if health.take_damage(damage):
			die()
			
func roll_initiative():
	initiative = randi() % 20
	
#override function
func take_turn():
	return
	
func die():
	queue_free()

func move(new_path):
	if move_speed <= 0 or max_move <= 0:
		print("cannot move")
	else:
		path = new_path
		path_index = 0
		t = 0

func attack(target_entity, attack_action):
	var in_range = attack_action.check_in_range(target_entity)
	var damage = attack_action.calculate_damage(target_entity)
	
	if in_range:
		target_entity.take_damage(damage)
	
	return in_range

func select():
	if is_selectable and selection:
		selection.set_selection_type(selection.MODE.selected_friend)
		
func deselect():
	if is_selectable and selection:
		selection.set_selection_type(selection.MODE.invisible)
		
func check_selected():
	if selection:
		return selection.is_selected
	else:
		return false

func _exit_tree() -> void:
	Messenger.ENTITY_DESTROYED.emit(self)


func _on_mouse_entered() -> void:
	entity_mouse_entered.emit(self)


func _on_mouse_exited() -> void:
	entity_mouse_exited.emit(self)
