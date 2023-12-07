class_name GameData
extends Resource

@export var save_name : String = "save"
@export var play_time : int = 0

@export var inventory : PlayerInventory = PlayerInventory.new()
@export var map_data : MapData = MapData.new()

@export var lair_expansions: Array[Enums.LAIR_EXPANSIONS]
