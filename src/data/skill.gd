extends Resource
class_name Skill

enum SkillType {
	ATTACK,
	MAGICATTACK,
	HEALING,
	BUFF,
	SPECIAL
}

@export var skill_name: String = ""
@export var skill_element: Elements.ElementType = Elements.ElementType.BLUNT
@export var skill_type: SkillType = SkillType.ATTACK

@export_group("Cost and Power")
@export var power: float = 1.0
@export var sp_cost: int = 0
