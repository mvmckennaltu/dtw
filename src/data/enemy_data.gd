class_name EnemyData
extends Resource


@export var enemy_name: String
@export var stats: Stats
@export var abilities: Array[String] = []
enum Affinity {
	NORMAL,
	STRONG,
	WEAK,
	NULLIFY
}

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
		Elements.ElementType.WIND:
			return wind_affinity

	return Affinity.NORMAL
