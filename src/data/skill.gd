extends Resource
class_name Skill

@export var skill_element: Elements

@export var skill_type: skill_types


enum skill_types
{
	ATTACK,
	MAGICATTACK,
	HEALING,
	BUFF,
	SPECIAL
}
