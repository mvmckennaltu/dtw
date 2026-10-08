extends PanelContainer

const TURN_ORDER_ENTRY = preload(
	"res://scene/ui/turn_order_entry.tscn"
)

@onready var turn_order_container: VBoxContainer = $VBoxContainer
@onready var battle_controller = $"../../BattleController"
func _ready():
	battle_controller.turn_order_created.connect(_on_turn_order_created)
func display_turn_order(order: Array[Battler]) -> void:
	# Remove the old entries.
	for child in turn_order_container.get_children():
		child.queue_free()
	
	# Create a new entry for every battler.
	for battler in order:
		var entry = TURN_ORDER_ENTRY.instantiate()
		turn_order_container.add_child(entry)
		entry.set_battler(battler)
func _on_turn_order_created(order: Array[Battler]) -> void:
	display_turn_order(order)
