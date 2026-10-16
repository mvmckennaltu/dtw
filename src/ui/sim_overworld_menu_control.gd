extends Control
class_name SimOverworldMenuController
@onready var main_menu = $MainOverworldMenu
@onready var shop_menu = $ShopMenu
@onready var shop_back_button = $ShopMenu/VBoxContainer/BackButton
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shop_menu.hide()
	main_menu.show()
	$MainOverworldMenu/VBoxContainer/EnterDungeonButton.grab_focus()


func return_to_main():
	shop_menu.hide()
	main_menu.show()
	$MainOverworldMenu/VBoxContainer/EnterDungeonButton.grab_focus()

func open_shop_menu():
	main_menu.hide()
	shop_menu.show()
	$ShopMenu/VBoxContainer/BackButton.grab_focus()


func _on_enter_dungeon_button_pressed() -> void:
	await Fade.fade_out(1, Color(0,0,0,1)).finished
	#TEMPORARY. Just so the test battle can start.
	get_tree().change_scene_to_file("uid://hi10d8yc4oxf")
	await Fade.fade_in(1, Color(0,0,0,1)).finished



func _on_shop_button_pressed() -> void:
	open_shop_menu()




func _on_back_button_pressed() -> void:
	return_to_main()
