extends Resource
class_name MainInventory
@export var consumable_inventory : Dictionary = {}
@export var equipment_inventory : Dictionary = {}
signal item_slot_full

func add_item_to_inventory(item: Item, amount: int):
	#Check for which type of item we're adding
	if item is Consumable:
		add_consumable_item_to_inventory(item, amount)
	elif item is Equipment:
		add_equippable_item_to_inventory(item, amount)
func remove_item_from_inventory(item: Item, amount: int):
	if item is Consumable:
		remove_consumable_item_from_inventory(item, amount)
	elif item is Equipment:
		remove_equippable_item_from_inventory(item, amount)
func add_consumable_item_to_inventory(item: Consumable, number_to_add: int):
	if consumable_inventory.has(item) && number_to_add > 0:
		consumable_inventory[item] = consumable_inventory[item] + number_to_add
		if consumable_inventory[item] > 255:
			item_slot_full.emit()
			consumable_inventory[item] = 255
	else:
		if number_to_add <= 255:
			consumable_inventory[item] = number_to_add
		else:
			consumable_inventory[item] = 255
func add_equippable_item_to_inventory(item: Equipment, number_to_add: int):
	if equipment_inventory.has(item) && number_to_add > 0:
		equipment_inventory[item] = equipment_inventory[item] + number_to_add
		if equipment_inventory[item] > 255:
			item_slot_full.emit()
			equipment_inventory[item] = 255
	else:
		if number_to_add <= 255:
			equipment_inventory[item] = number_to_add
		else:
			equipment_inventory[item] = 255
func remove_consumable_item_from_inventory(item: Consumable, number_to_remove: int):
	if consumable_inventory.has(item) && number_to_remove > 0:
		consumable_inventory[item] = consumable_inventory[item] - number_to_remove
		if consumable_inventory[item] <= 0:
			consumable_inventory.erase(item)
	else:
		return
func remove_equippable_item_from_inventory(item: Equipment, number_to_remove: int):
	if equipment_inventory.has(item) && number_to_remove > 0:
		equipment_inventory[item] = equipment_inventory[item] - number_to_remove
		if equipment_inventory[item] <= 0:
			equipment_inventory.erase(item)
	else:
		return
