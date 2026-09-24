class_name CharacterState
extends Resource

@export var definition: CharacterData

@export var level: int = 1
@export var experience: int = 0

@export var current_hp: int
@export var current_sp: int

@export var equipment: Array[Resource] = []
