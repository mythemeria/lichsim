extends Node

signal ENTITY_MOVED(init_pos, new_pos)
signal ENTITY_CREATED(entity)
signal ENTITY_DESTROYED(entity)
signal ENTITY_DAMAGED(entity)
signal ENTITY_SELECTED(entity)
signal ENTITY_DESELECTED(entity)

signal TURN_ENDED(entity)
signal TURN_STARTED(entity)
signal TURN_ORDER_ENTERED(entity, index)
signal TURN_ORDER_LEFT(entity)

signal MAIN_MENU_ENTER_DEBUG()
signal RESTORE_MAIN_MENU()

signal NEW_GAME()
signal DELETE_SAVE(save_file_name)
signal LOAD_SAVE(save_file_name)

signal SHOW_POPUP(popup_instance)

signal CHANGE_GAMEPLAY_MODE(new_mode)

signal INVENTORY_UPDATED()

signal ENABLE_PAUSE(is_enabled)
