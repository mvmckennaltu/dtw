extends Button

var battler: Battler

func set_battler(new_battler: Battler) -> void:
	battler = new_battler
	
	text = "{0}    DEX {1}".format([
		battler.name,
		str(battler.DEX)
	])
