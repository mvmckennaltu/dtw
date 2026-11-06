extends Control
class_name SimOverworldMenuController
@onready var main_menu = $MainOverworldMenu
@onready var shop_menu = $ShopMenu
@onready var crafting_menu = $CraftingMenu
@onready var shop_back_button = $ShopMenu/VBoxContainer/BackButton
@onready var recipe_list_object : CraftingList = preload("uid://dff7pax6utva0")
@onready var recipe_list = recipe_list_object.full_list
@onready var recipe_container = $CraftingMenu/VBoxContainer/RecipeContainer
var selected_recipe: CraftingRecipe
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shop_menu.hide()
	main_menu.show()
	crafting_menu.hide()
	$MainOverworldMenu/VBoxContainer/EnterDungeonButton.grab_focus()
	print(recipe_list)

func return_to_main():
	shop_menu.hide()
	main_menu.show()
	crafting_menu.hide()
	$ConfirmContainer.hide()
	$MainOverworldMenu/VBoxContainer/EnterDungeonButton.grab_focus()

func open_shop_menu():
	main_menu.hide()
	shop_menu.show()
	crafting_menu.hide()
	$ShopMenu/VBoxContainer/BackButton.grab_focus()

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
func _on_confirm_craft_button_pressed() -> void:
	if selected_recipe != null:
		craft_saccel(selected_recipe)
