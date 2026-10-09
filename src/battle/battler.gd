class_name Battler
extends Resource


var max_hp: int
var current_hp: int
var name: String
var max_sp: int
var current_sp: int

var STR: int
var DEX: int
var DEF: int
var LUC: int
var LVL: int


func take_damage(amount: int) -> void:
	current_hp = max(current_hp - amount, 0)

func heal(amount: int) -> void:
	current_hp = min(current_hp + amount, max_hp)


func is_alive() -> bool:
	return current_hp > 0

func setup(stats: Stats) -> void:
	max_hp = stats.max_hp
	current_hp = stats.max_hp
	max_sp = stats.max_sp
	current_sp = stats.max_sp
	STR = stats.STR
	DEX = stats.DEX
	DEF = stats.DEF
	LUC = stats.LUC
	LVL = stats.LVL
