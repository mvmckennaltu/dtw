extends RefCounted
class_name ItemUseContext

enum UseMode {
	OVERWORLD,
	BATTLE
}

var mode: UseMode

# Persistent character data
var user_state: CharacterState
var target_state: CharacterState

# Temporary battle data
var user_battler: Battler
var target_battler: Battler
