extends Control
class_name SimOverworldMenuController
@onready var main_menu = $MainOverworldMenu
@onready var shop_menu = $ShopMenu
@onready var crafting_menu = $CraftingMenu
@onready var shop_list = $ShopListMenu
@onready var shop_container = $ShopListMenu/VBoxContainer/ShopItems
@onready var shop_buy_button = $ShopMenu/VBoxContainer/BuyButton
@onready var shop_sell_button = $ShopMenu/VBoxContainer/SellButton
@onready var shop_talk_button = $ShopMenu/VBoxContainer/TalkButton
@onready var shop_back_button = $ShopMenu/VBoxContainer/BackButton
@onready var recipe_list_object : CraftingList = preload("uid://dff7pax6utva0")
@onready var recipe_list = recipe_list_object.full_list
@onready var recipe_container = $CraftingMenu/VBoxContainer/RecipeContainer
@onready var shop_list_item: ShopList = preload("uid://dqthd5p1fbs1w")
var selected_recipe: CraftingRecipe
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shop_menu.hide()
	main_menu.show()
	crafting_menu.hide()
	shop_list.hide()
	$MainOverworldMenu/VBoxContainer/EnterDungeonButton.grab_focus()
	print(recipe_list)

func return_to_main():
	shop_menu.hide()
	main_menu.show()
	shop_list.hide()
	crafting_menu.hide()
	$ConfirmContainer.hide()
	$MainOverworldMenu/VBoxContainer/EnterDungeonButton.grab_focus()
	$Money.hide()

func open_shop_menu():
	main_menu.hide()
	shop_menu.show()
	crafting_menu.hide()
	$ShopMenu/VBoxContainer/BackButton.grab_focus()
	$Money.text = "$" + str(PersistentParty.party.cura)
	$Money.show()
func open_crafting_menu():
	main_menu.hide()
	shop_menu.hide()
	crafting_menu.show()
	refresh_crafting_menu()
func _on_enter_dungeon_button_pressed() -> void:
	await Fade.fade_out(1, Color(0,0,0,1)).finished
	#TEMPORARY. Just so the test battle can start.
	get_tree().change_scene_to_file("uid://hi10d8yc4oxf")
	await Fade.fade_in(1, Color(0,0,0,1)).finished

func refresh_shop_menu():
	for item in shop_list_item.item_list:
		for child in shop_container.get_children():
			if child.has_meta("shop_item"):
				child.queue_free()
		print("making shop button")
		var button := Button.new()
		button.set_meta("shop_item", true)
		button.text = item.item_name + " $" + str(item.buy_price)
		shop_container.add_child(button)
		button.pressed.connect(buy_item.bind(item))
	$Money.text = "$" + str(PersistentParty.party.cura)
	
func refresh_crafting_menu():
	for recipe in recipe_list:
		for child in recipe_container.get_children():
			if child.has_meta("crafting_recipe"):
				child.queue_free()
		var is_available: bool = recipe_list[recipe]
		if is_available == true:
			print("making crafting button")
			var button := Button.new()
			button.set_meta("crafting_recipe", true)
			button.text = recipe.saccel_to_craft.saccel_name
			recipe_container.add_child(button)
			button.pressed.connect(open_confirm_menu.bind(recipe))
func open_confirm_menu(recipe: CraftingRecipe) -> void:
	var container := $ConfirmContainer/VBoxContainer
	selected_recipe = recipe
	# Remove the previous recipe's ingredient labels.
	for child in container.get_children():
		if child.has_meta("is_req"):
			child.queue_free()
	var insert_index := 0
	# Display the ingredients and required quantities.
	for item in recipe.required_ingredients:
		var amount: int = recipe.required_ingredients[item]

		var label := Label.new()
		label.set_meta("is_req", true)
		label.text = item.item_name + " " + str(amount) + "x"
		container.move_child(label,insert_index)
		container.add_child(label)
		insert_index + 1
	$ConfirmContainer/VBoxContainer/HBoxContainer.move_to_front()
	$ConfirmContainer/VBoxContainer.move_child($ConfirmContainer/VBoxContainer/Label2, $ConfirmContainer/VBoxContainer.get_child_count()-2)
	# Check whether the player can afford the recipe.
	var can_craft := has_required_ingredients(recipe)
	if can_craft:
		print("yay, you can craft!")
		$ConfirmContainer/VBoxContainer/Label2.text = "Craft?"
	else:
		print("rip")
		$ConfirmContainer/VBoxContainer/Label2.text = "You can't craft this."
	$ConfirmContainer/VBoxContainer/HBoxContainer.visible = can_craft
	
	$ConfirmContainer.show()
func _on_shop_button_pressed() -> void:
	open_shop_menu()




func _on_back_button_pressed() -> void:
	return_to_main()


func _on_sanc_button_pressed() -> void:
	open_crafting_menu()

func has_required_ingredients(recipe: CraftingRecipe) -> bool:
	var inventory: MainInventory = PersistentInventory.main_inventory

	for item in recipe.required_ingredients:
		var required_amount: int = recipe.required_ingredients[item]
		var owned_amount: int = inventory.get_item_count(item)

		if owned_amount < required_amount:
			return false

	return true

func craft_saccel(recipe: CraftingRecipe) -> void:
	var inventory: MainInventory = PersistentInventory.main_inventory

	# Check everything before modifying the inventory.
	if not has_required_ingredients(recipe):
		print("Not enough ingredients!")
		return

	# Consume the required ingredients.
	for item in recipe.required_ingredients:
		var amount: int = recipe.required_ingredients[item]
		inventory.remove_item_from_inventory(item, amount)

	print("Successfully crafted: ", recipe.saccel_to_craft.saccel_name)
	
	PersistentParty.party.members[0].soul_accelerators.append(recipe.saccel_to_craft)
	$ConfirmContainer.hide()
	refresh_crafting_menu()
func buy_item(item: Item):
	if PersistentParty.party.cura >= item.buy_price:
		PersistentParty.party.cura = PersistentParty.party.cura - item.buy_price
		PersistentInventory.main_inventory.add_item_to_inventory(item, 1)
		update_money()
	elif PersistentInventory.main_inventory.consumable_inventory.get(item) >= 255:
		$ShopListMenu/VBoxContainer/Label2.text = "You don't have any more space for this item!"
		await get_tree().create_timer(0.25).timeout
		$ShopListMenu/VBoxContainer/Label2.text = "Available Items"
	else:
		$ShopListMenu/VBoxContainer/Label2.text = "You don't have enough money!"
		await get_tree().create_timer(0.5).timeout
		$ShopListMenu/VBoxContainer/Label2.text = "Available Items"
func _on_confirm_craft_button_pressed() -> void:
	if selected_recipe != null:
		craft_saccel(selected_recipe)


func _on_buy_button_pressed() -> void:
	shop_menu.hide()
	shop_list.show()
	refresh_shop_menu()


func _on_sell_button_pressed() -> void:
	pass # Replace with function body.


func _on_talk_button_pressed() -> void:
	Dialogic.start("uid://cp1jt3vlkt1mo")

func update_money():
	$Money.text = "$" + str(PersistentParty.party.cura)
