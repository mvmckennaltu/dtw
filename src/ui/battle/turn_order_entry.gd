extends Button

var battler: Battler

func set_battler(new_battler: Battler) -> void:
	battler = new_battler
	if battler.is_enemy:
		
		text = "ENEMY    DEX {1}".format([
			battler.name,
			str(battler.DEX)
		])
	else:
		text = "{0}    DEX {1}".format([
			battler.name,
			str(battler.DEX)
		])
	

	
