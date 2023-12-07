extends Node

enum ENTITY_TYPE {
	player,
	enemy,
	environment
}

enum SLOT {
	head,	#0
	chest,	#1
	legs,	#2
	feet,	#3
	cape,	#4
	amulet,	#5
	hands,	#6
	ring,	#7
	weapon,	#8
	shield	#9
}

enum BODY_TYPE {
	none,
	humanoid
}

enum GAMEPLAY_MODE {
	main_menu,
	battle,
	map,
	lair
}

enum LAIR_EXPANSIONS {
	soul_forge
}

enum LOCATION_CLAIMS {
	unclaimed,
	player,
	enemy
}

enum CURSORMODE {
	default,
	disabled,
	summon,
	move,
	attack
}

enum SELECTMODE {
	disabled,
	default,
	terrain_position,
	entity_position,
	entity_collider
}

enum STATS {
	max_hp,
	strength,
	magic,
	max_move,
	move_speed
}
