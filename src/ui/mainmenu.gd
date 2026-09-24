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

	current_screen = screen

func _on_skills_button_pressed() -> void:
	show_screen(MenuScreen.SKILLS)


func _on_items_button_pressed() -> void:
	show_screen(MenuScreen.ITEMS)


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
