
extends Node3D
class_name DungeonItem

@export var item: Item
@export var amount: int = 1

func add_to_inv():
	PersistentInventory.main_inventory.add_item_to_inventory(item, amount)
	
	queue_free()
