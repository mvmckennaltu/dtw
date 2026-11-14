extends ItemEffect
class_name HealHPEffect

@export var healing_amount: int = 20

func apply(context: ItemUseContext) -> bool:

	if context.mode == ItemUseContext.UseMode.BATTLE:
		var target := context.target_battler

		if target == null or not target.is_alive():
			return false

		var old_hp := target.current_hp

		target.current_hp = mini(
			target.current_hp + healing_amount,
			target.max_hp
		)

		return target.current_hp > old_hp

	elif context.mode == ItemUseContext.UseMode.OVERWORLD:
		var target := context.target_state

		if target == null or target.current_hp <= 0:
			return false

		var old_hp := target.current_hp

		target.current_hp = mini(
			target.current_hp + healing_amount,
			target.get_max_hp()
		)

		return target.current_hp > old_hp

	return false
