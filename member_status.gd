extends PanelContainer

@onready var name_label: Label = $HBoxContainer/Name
@onready var current_hp_label: Label = $HBoxContainer/CurrentHPLabel
@onready var max_hp_label: Label = $HBoxContainer/MaxHPLabel
var battler: Battler

func set_battler(new_battler: Battler) -> void:
	battler = new_battler
	update_display()

func update_battler(battler: Battler) -> void:
	name_label.text = battler.name
	current_hp_label.text = str(battler.current_hp)
	max_hp_label.text = str(battler.max_hp)

func update_display() -> void:
	name_label.text = battler.name
	current_hp_label.text = str(battler.current_hp)
	max_hp_label.text = str(battler.max_hp)
