extends MenuScreenClass

var current_screen := MenuScreen.TOP
var last_selected : Control
var current_option
@export var remember_last_menu_option = false
@onready var content := $MenuPanel/VBoxContainer/Content
var menu_screens: Array[MenuScreenIdentifier]
var menu_stack : Array[MenuScreen] = [MenuScreen.TOP]
@onready var header_text = $MenuPanel/VBoxContainer/Header

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	get_viewport().gui_focus_changed.connect(_on_focus_changed)

	for child in content.get_children():
		if child is MenuScreenIdentifier:
			menu_screens.append(child)

	show_screen(MenuScreen.TOP)
	PersistentInventory.print_items()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("open_main_menu"):
		if visible == false:
			activate_menu()
		else:
			if current_screen == MenuScreen.TOP:
				deactivate_menu()
	
func activate_menu():
	visible = true
	get_tree().paused = true
	if remember_last_menu_option == false or last_selected == null:
		$MenuPanel/VBoxContainer/Content/TopMenu/VBoxContainer/SkillsButton.grab_focus.call_deferred()
	else:
		last_selected.grab_focus()
func deactivate_menu():
	last_selected = current_option
	release_focus()
	visible = false
	get_tree().paused = false
func _on_focus_changed(control:Control) -> void:
	if control != null:
		current_option = control
func show_screen(screen: MenuScreen) -> void:
	for menu in menu_screens:
		var is_selected := menu.menu_screen == screen
		
		menu.visible = is_selected
		
		if is_selected:
			header_text.text = menu.menu_label
			var vbox = menu.get_child(0)
			if vbox is VBoxContainer:
				var first_button = vbox.get_child(0)
				if first_button != null:
					first_button.grab_focus()
			elif vbox is ScrollContainer:
				var nested_vbox = vbox.get_child(0)
				var the_button = nested_vbox.get_child(0)
				the_button.grab_focus()
		
	current_screen = screen
	menu_stack.push_front(screen)
func return_to_previous_menu():
	menu_stack.pop_front()
	show_screen(menu_stack[0])
	
func show_items():
	var index = 0
	var values = PersistentInventory.consumables.values()
	for child in $MenuPanel/VBoxContainer/Content/ItemsMenu/ScrollContainer/VBoxContainer.get_children():
		if child.has_meta("Item"):
			child.queue_free()
	for item in PersistentInventory.get_items():
		var button = Button.new()
		var insert_index := 0
		print(item.item_name)
		button.text = item.item_name + ": " + str(values[index])
		print(str(index))
		index = index + 1
		$MenuPanel/VBoxContainer/Content/ItemsMenu/ScrollContainer/VBoxContainer.add_child(button)
		$MenuPanel/VBoxContainer/Content/ItemsMenu/ScrollContainer/VBoxContainer.move_child(button, insert_index)
		button.set_meta("Item", true)
		insert_index = insert_index + 1
		var first_item = $MenuPanel/VBoxContainer/Content/ItemsMenu/ScrollContainer/VBoxContainer.get_child(0)
		first_item.grab_focus()
func _on_skills_button_pressed() -> void:
	show_screen(MenuScreen.SKILLS)


func _on_items_button_pressed() -> void:
	show_screen(MenuScreen.ITEMS)
	show_items()

func _on_s_accel_button_pressed() -> void:
	show_screen(MenuScreen.SACCEL)


func _on_equipment_button_pressed() -> void:
	show_screen(MenuScreen.EQUIPMENT)


func _on_stats_button_pressed() -> void:
	show_screen(MenuScreen.STATS)


func _on_save_button_pressed() -> void:
	show_screen(MenuScreen.SAVE)


func _on_load_button_pressed() -> void:
	show_screen(MenuScreen.LOAD)


func _on_sys_button_pressed() -> void:
	show_screen(MenuScreen.SYSTEM)


func _on_skills_back_pressed() -> void:
	return_to_previous_menu()


func _on_items_back_pressed() -> void:
	return_to_previous_menu()


func _on_s_accel_back_pressed() -> void:
	return_to_previous_menu()


func _on_stats_back_pressed() -> void:
	return_to_previous_menu()


func _on_save_back_pressed() -> void:
	return_to_previous_menu()


func _on_load_back_pressed() -> void:
	return_to_previous_menu()


func _on_sys_back_pressed() -> void:
	return_to_previous_menu()
	


func _on_equipment_back_pressed() -> void:
	return_to_previous_menu()
