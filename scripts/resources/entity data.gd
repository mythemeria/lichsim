class_name EntityData
extends Resource

@export var scene : PackedScene

@export_group("gear")
@export var override_gear : bool = false
@export var gear : Gear
@export var additional_actions : Array[Resource]

@export_group("stats")
@export var override_stats : bool = false
@export var max_hp = 0
@export var strength = 0
@export var magic = 0
@export var max_move = 0
@export var move_speed = 0

@export_group("avatar")
@export var override_avatar : bool = false
@export var avatar : Texture2D
