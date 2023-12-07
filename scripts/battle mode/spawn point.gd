@tool
extends Node3D

var colour_dict = {
	Enums.ENTITY_TYPE.player : Color.DARK_ORCHID,
	Enums.ENTITY_TYPE.enemy : Color.GOLD,
	Enums.ENTITY_TYPE.environment : Color.FOREST_GREEN
}

@onready var mesh: MeshInstance3D = $MeshInstance3D
var colour


@export var entity_type : Enums.ENTITY_TYPE:
	set(value):
		entity_type = value
		colour = colour_dict[entity_type]
		if Engine.is_editor_hint():
			mesh.mesh.material.albedo_color = colour

func _ready() -> void:
	
	if (!Debug.enabled or !Debug.show_spawn_points) and !Engine.is_editor_hint():
		mesh.visible = false

