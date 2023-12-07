extends Action
class_name Attack

@export var base_damage = 0
@export_enum("fire", "ice", "lightning", "piercing", "bludgeoning") var damage_type
 
func calculate_damage(_target):
	return base_damage 
	
func check_in_range(_target):
	return true
