
extends Resource
class_name SAccel

enum Affinity {
	NORMAL,
	STRONG,
	WEAK,
	NULLIFY
}

@export var saccel_name: String = ""
@export var skills: Array[Skill] = []

@export_group("Stat Modifiers")
@export var STR_modifier: int = 0
@export var DEX_modifier: int = 0
@export var DEF_modifier: int = 0
@export var LUC_modifier: int = 0

@export_group("Elemental Affinities")
@export var blunt_affinity: Affinity = Affinity.NORMAL
@export var sharp_affinity: Affinity = Affinity.NORMAL
@export var fire_affinity: Affinity = Affinity.NORMAL
@export var earth_affinity: Affinity = Affinity.NORMAL
@export var water_affinity: Affinity = Affinity.NORMAL
@export var wind_affinity: Affinity = Affinity.NORMAL


func get_affinity(element: Elements.ElementType) -> Affinity:
	match element:
		Elements.ElementType.BLUNT:
			return blunt_affinity
		Elements.ElementType.SHARP:
			return sharp_affinity
		Elements.ElementType.FIRE:
			return fire_affinity
		Elements.ElementType.EARTH:
			return earth_affinity
		Elements.ElementType.WATER:
			return water_affinity

	return wind_affinity if element == Elements.ElementType.WIND else Affinity.NORMAL
