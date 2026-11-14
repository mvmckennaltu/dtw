extends Resource
class_name Item

@export var item_name: String
@export var item_effect: ItemEffect

func item_use(context: ItemUseContext) -> bool:
	if item_effect == null:
		return false

	return item_effect.apply(context)
