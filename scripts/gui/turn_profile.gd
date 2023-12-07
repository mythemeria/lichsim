extends Button

@onready var TurnEngine = get_parent()

enum TYPE {
	unset,
	player,
	enemy,
	environment
}

var profile_type = TYPE.unset
var associated_entity

signal profile_selected(profile)

func _ready() -> void:
	set_profile_active(false)

func set_profile_type(type):
	profile_type = type

func set_profile_active(is_active):
	if is_active:
		custom_minimum_size.x = 80
		custom_minimum_size.y = 80
	else:
		custom_minimum_size.x = 56
		custom_minimum_size.y = 56


func _on_pressed() -> void:
	profile_selected.emit(self)
