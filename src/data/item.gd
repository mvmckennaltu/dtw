extends Resource
class_name Item

@export var item_name: String
@export var item_effect: ItemEffect
@export var sellable: bool = true
@export var buy_price : int
@export var sell_price : int = (buy_price/2)
func item_use(context: ItemUseContext) -> bool:
	if item_effect == null:
		return false

	return item_effect.apply(context)
