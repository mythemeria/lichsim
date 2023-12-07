extends ItemList

var player_entity_array = []

func _ready() -> void:
	Messenger.connect("ENTITY_CREATED", _on_entity_created)
	Messenger.connect("ENTITY_DESTROYED", _on_entity_destroyed)
	Messenger.connect("ENTITY_DAMAGED", _on_entity_damaged)
	Messenger.connect("ENTITY_SELECTED", _on_entity_selected)
	Messenger.connect("ENTITY_DESELECTED", _on_entity_deselected)

func add_dude(dude):
	add_item("id: " + str(item_count), dude.avatar, true)
	player_entity_array.append(dude)

func _on_entity_selected(entity) -> void:
	var result = player_entity_array.find(entity)
	if result != -1:
		select(result, false)
	
func _on_entity_deselected(entity) -> void:
	var result = player_entity_array.find(entity)
	if result != -1:
		deselect(result)

func _on_entity_created(entity) -> void:
	if entity.entity_type == Enums.ENTITY_TYPE.player:
		add_dude(entity)

func _on_entity_destroyed(entity) -> void:
	var dude_list_index = player_entity_array.find(entity)
	if dude_list_index != -1:
		remove_item(dude_list_index)
		player_entity_array.erase(entity)

func _on_item_clicked(index: int, _at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == 1:
		Messenger.ENTITY_SELECTED.emit(player_entity_array[index])
		
func _on_entity_damaged(entity):
	var index = player_entity_array.find(entity)
	if index != -1:
		var dude = player_entity_array[index]
		if dude:
			set_item_text(index, str(dude.health.current_health))
		
		
