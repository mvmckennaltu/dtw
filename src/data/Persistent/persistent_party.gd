extends Node
class_name persistent_party

@export var party = preload("uid://bad0rnyjjj5bn")
func _ready():
	Dialogic.signal_event.connect(_on_dialogic_signal)

func _on_dialogic_signal(argument:String):
	if argument == "SimVictoriaJoins":
		party.members.append(load("uid://bmh0vtivq7jr4"))
