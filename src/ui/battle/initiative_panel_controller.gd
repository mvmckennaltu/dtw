extends PanelContainer

const TURN_ORDER_ENTRY = preload(
	"res://scene/ui/turn_order_entry.tscn"
)
var is_editing_order := false
var selected_battler: Battler = null
var selected_entry: Control = null
@onready var turn_order_container: VBoxContainer = $VBoxContainer
@onready var battle_controller = $"../../../BattleController"
func _ready():
	battle_controller.turn_order_created.connect(_on_turn_order_created)
	battle_controller.turn_order_changed.connect(_on_turn_order_changed)
func display_turn_order(order: Array[Battler]) -> void:
	selected_battler = null
	selected_entry = null

	for child in turn_order_container.get_children():
		child.queue_free()

	for battler in order:
		var entry = TURN_ORDER_ENTRY.instantiate()
		turn_order_container.add_child(entry)
		entry.set_battler(battler)
		entry.set_meta("battler", battler)
		# Clicking an entry lets the player select a party member.
		if entry is BaseButton:
			entry.pressed.connect(
				_on_turn_order_entry_pressed.bind(battler, entry)
			)
func _on_turn_order_created(order: Array[Battler]) -> void:
	display_turn_order(order)
func _on_turn_order_changed(order: Array[Battler]) -> void:
	display_turn_order(order)
	
func _on_turn_order_entry_pressed(battler: Battler,entry: Control) -> void:
	if not is_editing_order:
		return
	# Swapping is only allowed while planning the round.
	if battle_controller.battle_state != BattleController.BattleState.COMMAND:
		return

	# Enemies cannot be selected for swapping.
	if not battle_controller.party_battlers.has(battler):
		return

	# First click selects a party member.
	if selected_battler == null:
		selected_battler = battler
		selected_entry = entry
		selected_entry.modulate = Color(1.0, 0.8, 0.4)
		return

	# Clicking the same member again deselects them.
	if selected_battler == battler:
		selected_entry.modulate = Color.WHITE
		selected_battler = null
		selected_entry = null
		return

	# Second click requests a swap through the controller.
	battle_controller.swap_party_members(
		selected_battler,
		battler
	)
	var battler_to_focus := battler
	# Clear the selection. The changed-order signal redraws the panel.
	selected_battler = null
	selected_entry = null
	await get_tree().create_timer(0.1).timeout
	restore_focus_to_battler.call_deferred(battler_to_focus)
func set_editing_enabled(enabled: bool) -> void:
	is_editing_order = enabled

	selected_battler = null
	selected_entry = null

	for child in turn_order_container.get_children():
		if child is Control:
			child.mouse_filter = (
				Control.MOUSE_FILTER_STOP
				if enabled
				else Control.MOUSE_FILTER_IGNORE
			)

		if child is BaseButton:
			child.disabled = not enabled
func focus_first_entry() -> void:
	for child in turn_order_container.get_children():
		if child is BaseButton and not child.disabled:
			child.grab_focus()
			return
func restore_focus_to_battler(battler: Battler) -> void:
	for child in turn_order_container.get_children():
		if (
			child is BaseButton
			and child.get_meta("battler", null) == battler
			and not child.disabled
		):
			child.grab_focus()
			return
