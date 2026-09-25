extends Node3D

@onready var battle_controller = $BattleController

func _ready() -> void:
	battle_controller.start_battle()
	$CanvasLayer/ActionSelect/VBoxContainer/AttackButton.grab_focus()
