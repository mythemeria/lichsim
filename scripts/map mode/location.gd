extends StaticBody3D

@onready var mesh: MeshInstance3D = $MeshInstance3D
var material

var selected_colour = Color("00ff15")
var default_colour = Color("ff0000")

func _ready() -> void:
	material = mesh.get_active_material(0).duplicate()
	mesh.material_override = material

func set_selected(is_selected):
	match is_selected:
		true:
			material.albedo_color = selected_colour
		false:
			material.albedo_color = default_colour
