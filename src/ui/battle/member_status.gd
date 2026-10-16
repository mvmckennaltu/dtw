extends PanelContainer

@onready var name_label: Label = $VBoxContainer/HBoxContainer/Name
@onready var current_hp_label: Label = $VBoxContainer/HBoxContainer/CurrentHPLabel
@onready var max_hp_label: Label = $VBoxContainer/HBoxContainer/MaxHPLabel
@onready var current_sp_label: Label = $VBoxContainer/HBoxContainer2/CurrentSPLabel
@onready var max_sp_label: Label = $VBoxContainer/HBoxContainer2/MaxSPLabel
var battler: Battler

func set_battler(new_battler: Battler) -> void:
	battler = new_battler
	update_display()

func update_battler(battler: Battler) -> void:
	name_label.text = battler.name
	current_hp_label.text = str(battler.current_hp)
	max_hp_label.text = str(battler.max_hp)
	current_sp_label.text = str(battler.current_sp)
	max_sp_label.text = str(battler.max_sp)

func update_display() -> void:
	name_label.text = battler.name
	current_hp_label.text = str(battler.current_hp)
	max_hp_label.text = str(battler.max_hp)
	current_sp_label.text = str(battler.current_sp)
	max_sp_label.text = str(battler.max_sp)
