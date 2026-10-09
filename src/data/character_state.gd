
class_name CharacterState
extends Resource

@export var definition: CharacterData

@export var level: int = 1
@export var experience: int = 0

@export var current_hp: int = 0
@export var current_sp: int = 0

@export var equipment: Array[Resource] = []
@export var soul_accelerators: Array[SAccel] = []
@export var equipped_saccel: SAccel


func equip_saccel(saccel: SAccel) -> bool:
	# The character must actually own this SAccel.
	if saccel == null:
		return false

	if not soul_accelerators.has(saccel):
		return false

	equipped_saccel = saccel
	return true


func get_available_skills() -> Array[Skill]:
	var available: Array[Skill] = []

	# The universal melee attack is always available.
	if definition != null and definition.melee_skill != null:
		available.append(definition.melee_skill)

	# Add the equipped SAccel's skills.
	if equipped_saccel != null:
		for skill in equipped_saccel.skills:
			if skill != null and not available.has(skill):
				available.append(skill)

	return available


func get_base_stats() -> Stats:
	if definition == null:
		return null

	return definition.base_stats


func get_effective_str() -> int:
	var stats := get_base_stats()
	if stats == null:
		return 0

	var modifier := 0
	if equipped_saccel != null:
		modifier = equipped_saccel.STR_modifier

	return stats.STR + modifier


func get_effective_dex() -> int:
	var stats := get_base_stats()
	if stats == null:
		return 0

	var modifier := 0
	if equipped_saccel != null:
		modifier = equipped_saccel.DEX_modifier

	return stats.DEX + modifier


func get_effective_def() -> int:
	var stats := get_base_stats()
	if stats == null:
		return 0

	var modifier := 0
	if equipped_saccel != null:
		modifier = equipped_saccel.DEF_modifier

	return stats.DEF + modifier


func get_effective_luc() -> int:
	var stats := get_base_stats()
	if stats == null:
		return 0

	var modifier := 0
	if equipped_saccel != null:
		modifier = equipped_saccel.LUC_modifier

	return stats.LUC + modifier


func get_max_hp() -> int:
	var stats := get_base_stats()
	if stats == null:
		return 0

	return stats.max_HP


func get_max_sp() -> int:
	var stats := get_base_stats()
	if stats == null:
		return 0

	return stats.max_SP

func get_elemental_affinity(
	element: Elements.ElementType
) -> SAccel.Affinity:
	if equipped_saccel == null:
		return SAccel.Affinity.NORMAL

	return equipped_saccel.get_affinity(element)


func initialize_resources() -> void:
	# Call when creating a new character, not every time
	# a battle starts or the character is loaded.
	current_hp = get_max_hp()
	current_sp = get_max_sp()
