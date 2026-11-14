extends MenuScreenClass

var current_screen := MenuScreen.TOP
var last_selected : Control
var current_option
@export var remember_last_menu_option = false
@onready var content := $MenuPanel/VBoxContainer/Content
var menu_screens: Array[MenuScreenIdentifier]
var menu_stack : Array[MenuScreen] = [MenuScreen.TOP]
@onready var header_text = $MenuPanel/VBoxContainer/Header
var selected_item: Item = null
var selecting_item_target := false

@onready var items_container: VBoxContainer = \
	$MenuPanel/VBoxContainer/Content/ItemsMenu/ScrollContainer/VBoxContainer
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
func return_to_previous_menu() -> void:
	if menu_stack.size() <= 1:
		deactivate_menu()
		return

	# Discard the screen we're leaving.
	menu_stack.pop_front()

	# Display the new top of the stack.
	var previous_screen: MenuScreen = menu_stack.front()
	show_screen(previous_screen)
	
func show_items() -> void:
	selecting_item_target = false
	selected_item = null

	for child in items_container.get_children():
		if child.has_meta("Item") or child.has_meta("ItemTarget"):
			child.queue_free()

	var inventory: MainInventory = PersistentInventory.main_inventory

	for item in inventory.consumable_inventory:
		var amount: int = inventory.get_item_count(item)

		if amount <= 0:
			continue

		var button := Button.new()
		button.text = item.item_name + " x" + str(amount)
		button.set_meta("Item", true)

		button.pressed.connect(
			select_item_for_use.bind(item)
		)

		items_container.add_child(button)

	# Give the first generated item keyboard/controller focus.
	for child in items_container.get_children():
		if child is BaseButton and not child.disabled:
			child.grab_focus.call_deferred()
			break
func show_saccels():
	for child in $MenuPanel/VBoxContainer/Content/SAccelMenu/VBoxContainer.get_children():
		if child.has_meta("party_member_entry"):
			child.queue_free()
	var party = PersistentParty.party
	var insert_index := 0
	for member in party.members:
		var button = Button.new()
		$MenuPanel/VBoxContainer/Content/SAccelMenu/VBoxContainer.add_child(button)
		button.text = member.definition.character_name
		$MenuPanel/VBoxContainer/Content/SAccelMenu/VBoxContainer.move_child(button, insert_index)
		button.set_meta("party_member_entry", true)
		insert_index = insert_index + 1
		button.pressed.connect(show_member_saccels.bind(member))
		$MenuPanel/VBoxContainer/Content/SAccelMenu/VBoxContainer.get_child(0).grab_focus()
func show_member_saccels(member: CharacterState) -> void:
	push_screen(MenuScreen.CHARACTERSACCELS)
	refresh_member_saccels(member)


func refresh_member_saccels(member: CharacterState) -> void:
	var container := $MenuPanel/VBoxContainer/Content/CharacterSAccelsMenu/VBoxContainer

	for child in container.get_children():
		if child.has_meta("saccel_entry"):
			child.queue_free()

	header_text.text = member.definition.character_name

	for saccel in member.soul_accelerators:
		var button := Button.new()

		if saccel == member.equipped_saccel:
			button.text = saccel.saccel_name + " (Equipped)"
		else:
			button.text = saccel.saccel_name

		button.set_meta("saccel_entry", true)
		container.add_child(button)
		button.pressed.connect(
			change_member_saccel.bind(member, saccel)
		)
	container.get_child(0).grab_focus()

func change_member_saccel(
	member: CharacterState,
	saccel: SAccel
) -> void:
	if not member.equip_saccel(saccel):
		return

	refresh_member_saccels(member)
func push_screen(screen : MenuScreen):
	if screen == current_screen:
		return
	menu_stack.push_front(screen)
	show_screen(screen)
func show_equipment():
	for child in $MenuPanel/VBoxContainer/Content/EquipmentMenu/VBoxContainer.get_children():
		if child.has_meta("party_member_entry"):
			child.queue_free()
	var party = PersistentParty.party
	var insert_index := 0
	for member in party.members:
		var button = Button.new()
		$MenuPanel/VBoxContainer/Content/EquipmentMenu/VBoxContainer.add_child(button)
		button.text = member.definition.character_name
		$MenuPanel/VBoxContainer/Content/EquipmentMenu/VBoxContainer.move_child(button, insert_index)
		button.set_meta("party_member_entry", true)
		insert_index = insert_index + 1
		button.pressed.connect(show_member_equipment.bind(member))
	$MenuPanel/VBoxContainer/Content/EquipmentMenu/VBoxContainer.get_child(0).grab_focus()
func show_member_equipment(member: CharacterState):
	push_screen(MenuScreen.CHARACTEREQUIPMENT)
	refresh_member_equipment(member)
	
func refresh_member_equipment(member: CharacterState) -> void:
	var container := $MenuPanel/VBoxContainer/Content/CharacterEquipmentMenu/VBoxContainer

	for child in container.get_children():
		if child.has_meta("equipment_entry"):
			child.queue_free()

	header_text.text = member.definition.character_name
	var equipment :Array[Equipment] = [member.armor,member.weapon,member.accessory,member.gun]
	for item in equipment:
		if item == null:
			return
		var button := Button.new()
		
		button.text = item.item_name

		button.set_meta("equipment_entry", true)
		container.add_child(button)
	container.get_child(0).grab_focus()
func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if not event.is_action_pressed("ui_cancel"):
		return

	get_viewport().set_input_as_handled()

	if selecting_item_target:
		show_items()
		return

	if menu_stack.size() > 1:
		return_to_previous_menu()
	else:
		deactivate_menu()

func _on_skills_button_pressed() -> void:
	push_screen(MenuScreen.SKILLS)


func _on_items_button_pressed() -> void:
	push_screen(MenuScreen.ITEMS)
	show_items()

func _on_s_accel_button_pressed() -> void:
	push_screen(MenuScreen.SACCEL)
	show_saccels()

func _on_equipment_button_pressed() -> void:
	push_screen(MenuScreen.EQUIPMENT)
	show_equipment()

func _on_stats_button_pressed() -> void:
	push_screen(MenuScreen.STATS)


func _on_save_button_pressed() -> void:
	push_screen(MenuScreen.SAVE)


func _on_load_button_pressed() -> void:
	push_screen(MenuScreen.LOAD)


func _on_sys_button_pressed() -> void:
	push_screen(MenuScreen.SYSTEM)


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


func _on_chara_s_accel_back_pressed() -> void:
	return_to_previous_menu()

func select_item_for_use(item: Item) -> void:
	selected_item = item
	selecting_item_target = true

	# Clear the old item buttons.
	for child in items_container.get_children():
		if child.has_meta("Item") or child.has_meta("ItemTarget"):
			child.queue_free()

	header_text.text = "Use " + item.item_name + " on who?"

	# Generate a button for every party member.
	for member in PersistentParty.party.members:
		var button := Button.new()
		button.text = member.definition.character_name
		button.set_meta("ItemTarget", true)

		button.pressed.connect(
			use_item_on_character.bind(member)
		)

		items_container.add_child(button)

	# Focus the first available character.
	for child in items_container.get_children():
		if child is BaseButton and not child.disabled:
			child.grab_focus.call_deferred()
			break
func use_item_on_character(target: CharacterState) -> void:
	if selected_item == null:
		return

	var inventory: MainInventory = PersistentInventory.main_inventory

	# Make sure the item is still available.
	if inventory.get_item_count(selected_item) <= 0:
		return

	# Construct the overworld item-use context.
	var context := ItemUseContext.new()
	context.mode = ItemUseContext.UseMode.OVERWORLD
	context.target_state = target

	# Apply the effect.
	var successful := selected_item.item_use(context)

	if not successful:
		print("The item had no effect!")
		return

	# Consume one item only after successful use.
	inventory.remove_item_from_inventory(selected_item, 1)

	print(
		"Used ", selected_item.item_name,
		" on ", target.definition.character_name
	)

	# Return to the item list and refresh quantities.
	show_items()
