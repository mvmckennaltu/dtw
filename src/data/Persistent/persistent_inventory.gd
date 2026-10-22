extends Node

var main_inventory : MainInventory = load("res://database/party/test_inventory.tres")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func print_items():
	for item in main_inventory.consumable_inventory:
		print(item)
