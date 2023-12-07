extends Node3D

var max_health = 0
var current_health = 0

var health_bar_scene = preload("res://scenes/entity/health bar.tscn")
var health_bar

func set_max_health(new_health):
	max_health = new_health
	
#returns true if the entity should be destroyed
func take_damage(damage):
	current_health -= damage
	if health_bar:
		health_bar.frame = max(ceil( float(current_health) / (float(max_health) / 100)), 0)
	Messenger.ENTITY_DAMAGED.emit(get_parent())
	return current_health <= 0

func _ready() -> void:
	current_health = max_health

func add_health_bar():
	health_bar = health_bar_scene.instantiate()
	health_bar.frame = 100
	add_child(health_bar)
