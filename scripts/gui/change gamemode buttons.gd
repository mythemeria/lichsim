extends VBoxContainer

var current_mode

@onready var map: Button = $Map
@onready var lair: Button = $Lair
@onready var battle: Button = $Battle


func _ready() -> void:
	match current_mode:
		Enums.GAMEPLAY_MODE.map:
			map.queue_free()
		Enums.GAMEPLAY_MODE.battle:
			battle.queue_free()
		Enums.GAMEPLAY_MODE.lair:
			lair.queue_free()

func _on_map_pressed() -> void:
	Messenger.CHANGE_GAMEPLAY_MODE.emit(Enums.GAMEPLAY_MODE.map)


func _on_lair_pressed() -> void:
	Messenger.CHANGE_GAMEPLAY_MODE.emit(Enums.GAMEPLAY_MODE.lair)


func _on_battle_pressed() -> void:
	Messenger.CHANGE_GAMEPLAY_MODE.emit(Enums.GAMEPLAY_MODE.battle)
