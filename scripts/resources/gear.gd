extends Resource
class_name Gear

@export_enum("none", "humanoid") var body_type

#gear dictionary
@export var slots = {
	Enums.SLOT.head		: null,
	Enums.SLOT.chest	: null,
	Enums.SLOT.legs		: null,
	Enums.SLOT.feet		: null,
	Enums.SLOT.cape		: null,
	Enums.SLOT.amulet	: null,
	Enums.SLOT.hands	: null,
	Enums.SLOT.ring		: null,
	Enums.SLOT.weapon	: null,
	Enums.SLOT.shield	: null
}
