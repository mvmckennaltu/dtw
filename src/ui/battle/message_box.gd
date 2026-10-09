extends Label

@onready var battle_controller: BattleController = $"../../../../BattleController"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	battle_controller.update_message_text.connect(_on_battle_controller_update_message_text)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_battle_controller_update_message_text(message: String) -> void:
	text = message
