extends Node3D

@onready var battle_controller = $BattleController

func _ready() -> void:
	battle_controller.start_battle()
	$CanvasLayer/BattleMenuControl/MainActionSelect/VBoxContainer/StratButton.grab_focus()
