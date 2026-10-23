class_name Encounter
extends Resource

@export var enemies: Array[EnemyData] = []
@export var victory_xp : int
@export var item_drops: Dictionary = {}
func _ready():
	for enemy in enemies:
		victory_xp += enemy.xp_drop
