extends Control
class_name BattleMenuController
@onready var main_action_select = $MainActionSelect
@onready var strategy_menu = $StrategyMenu
@onready var skill_menu = $SkillMenu
@onready var order_menu = $OrderMenu
@onready var battle_controller = $"../../BattleController"
@onready var start_button = $MainActionSelect/VBoxContainer/StartBattleButton
@onready var strategy_container: VBoxContainer = $StrategyMenu/VBoxContainer
@onready var message_box = $MessageContainer/MessageBox
@onready var initiative_panel_controller = \
	$InitiativePanel

@onready var swap_order_button: Button = \
	$StrategyMenu/VBoxContainer/SwapOrderButton

@onready var strategy_back_button: Button = \
	$StrategyMenu/VBoxContainer/BackButton

@onready var order_back_button: Button = \
	$OrderMenu/VBoxContainer/BackButton
var selected_command_battler: Battler = null
signal battle_start
signal all_attack
func _ready() -> void:
	main_action_select.show()
	strategy_menu.hide()
	skill_menu.hide()
	order_menu.hide()
func open_strategy_menu() -> void:
	main_action_select.hide()
	skill_menu.hide()
	order_menu.hide()
	refresh_strategy_menu()
	strategy_menu.show()
	for child in strategy_container.get_children():
		if child is Button:
			child.grab_focus()
			return 


func open_skill_menu(battler: Battler) -> void:
	selected_command_battler = battler
	var skill_button = $SkillMenu/VBoxContainer.get_child(0)
	skill_button.grab_focus()
	strategy_menu.hide()
	skill_menu.show()


func open_order_menu() -> void:
	strategy_menu.hide()
	order_menu.show()

	initiative_panel_controller.set_editing_enabled(true)

	# Move keyboard/controller focus to the first turn-order entry.
	initiative_panel_controller.focus_first_entry()


func return_to_strategy() -> void:
	initiative_panel_controller.set_editing_enabled(false)

	order_menu.hide()
	skill_menu.hide()
	strategy_menu.show()

	refresh_strategy_menu()
	swap_order_button.grab_focus()


func return_to_main_menu() -> void:
	strategy_menu.hide()
	skill_menu.hide()
	order_menu.hide()
	main_action_select.show()
	$MainActionSelect/VBoxContainer/StratButton.grab_focus()
func refresh_strategy_menu() -> void:
	for child in strategy_container.get_children():
		if child.has_meta("party_member_button"):
			child.queue_free()

	var insert_index := 0

	# Follow the actual initiative order.
	for battler in battle_controller.turn_order:
		# Skip enemies.
		if not battle_controller.party_battlers.has(battler):
			continue

		# Skip defeated party members.
		if not battler.is_alive():
			continue

		var button := Button.new()
		button.set_meta("party_member_button", true)
		button.text = battler.name

		var action = battle_controller.planned_actions.get(battler)

		if action != null:
			button.text += " — " + action_name(action)
		else:
			button.text += " — Not selected"

		button.pressed.connect(
			open_skill_menu.bind(battler)
		)

		strategy_container.add_child(button)
		strategy_container.move_child(button, insert_index)
		insert_index += 1
func action_name(action: int) -> String:
	match action:
		battle_controller.ActionType.NORMAL_ATTACK:
			return "Attack"
		battle_controller.ActionType.STRONG_ATTACK:
			return "Strong Attack"
		_:
			return "Unknown action"
func _on_attack_button_pressed() -> void:
	if selected_command_battler == null:
		return

	battle_controller.queue_action(
		selected_command_battler,
		battle_controller.ActionType.NORMAL_ATTACK
	)

	return_to_strategy()
	refresh_strategy_menu()
func _on_strat_button_pressed() -> void:
	open_strategy_menu()
	
	


func _on_start_battle_button_pressed() -> void:
	battle_start.emit()



func _on_strategy_back_button_pressed() -> void:
	return_to_main_menu()


func _on_swap_order_button_pressed() -> void:
	open_order_menu()





func _on_skill_back_button_pressed() -> void:
	return_to_strategy()





func _on_order_back_button_pressed() -> void:
	return_to_strategy()


func _on_strong_attack_button_pressed() -> void:
	if selected_command_battler == null:
		return

	battle_controller.queue_action(
		selected_command_battler,
		battle_controller.ActionType.STRONG_ATTACK
	)
	return_to_strategy()


func _on_all_attack_button_pressed() -> void:
	all_attack.emit()
	refresh_strategy_menu()
