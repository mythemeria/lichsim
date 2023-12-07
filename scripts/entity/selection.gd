extends Node3D

#depreciated
var is_selected = false

var mode

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var material: StandardMaterial3D = $MeshInstance3D.get_active_material(0)
var solid = preload("res://assets/images/selection2.png")
var dashed = preload("res://assets/images/selection.png")

enum MODE {
	invisible,
	hover,
	selected_friend,
	selected_foe,
	valid_target,
	invalid_target,
	friendly_fire
}

func _ready() -> void:
	material = material.duplicate()
	mesh.material_override = material

#depreciated
func set_selected(set_bool):
	is_selected = set_bool

func make_visible(set_bool):
	mesh.visible = set_bool
	
func set_selection_type(type):
	mode = type
	
	match mode:
		MODE.invisible:
			set_selected(false)
			make_visible(false)
		MODE.hover:
			set_selected(false)
			make_visible(true)
			material.albedo_texture = dashed
			material.albedo_color = Color(1, 1, 1, 1)
		MODE.selected_friend:
			set_selected(true)
			make_visible(true)
			material.albedo_texture = solid
			material.albedo_color = Color(1, 1, 1, 1)
		MODE.selected_foe:
			set_selected(true)
			make_visible(true)
			material.albedo_texture = solid
			material.albedo_color = Color(1, 0, 0, 1)
		MODE.valid_target:
			set_selected(false)
			make_visible(true)
			material.albedo_texture = dashed
			material.albedo_color = Color(0, 1, 0, 1)
		MODE.invalid_target:
			set_selected(false)
			make_visible(true)
			material.albedo_texture = dashed
			material.albedo_color = Color(1, 0, 0, 1)
		MODE.friendly_fire:
			set_selected(false)
			make_visible(true)
			material.albedo_texture = dashed
			material.albedo_color = Color(1, 0.4, 0, 1)
