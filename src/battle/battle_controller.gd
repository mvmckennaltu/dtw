extends Node3D
enum BattleState {
	START,
	PLAYER_TURN,
	ENEMY_TURN,
	VICTORY,
	DEFEAT,
	COMMAND
}
enum ActionType {
	NORMAL_ATTACK,
	STRONG_ATTACK
}
@export var party: Party
@export var encounter: Encounter
var planned_actions: Dictionary = {}
var turn_order: Array[Battler] = []
var current_turn_index := 0

var party_battlers: Array[Battler] = []
var enemy_battlers: Array[Battler] = []
var initial_turn_order: Array[Battler] = []
var battle_state: BattleState
signal send_current_hp(value: int)
signal send_max_hp(value: int)
signal battler_hp_changed(battler: Battler)
signal update_message_text(message: String)
signal party_created(party_battlers: Array[Battler])
signal turn_order_created(turn_order: Array[Battler])
signal turn_order_changed(turn_order: Array[Battler])
func start_battle() -> void:
	party_battlers.clear()
	enemy_battlers.clear()
	turn_order.clear()
	current_turn_index = 0
	var message := "{0} enemies wish to fight!"
	create_party_battlers()
	create_enemy_battlers()
	update_message_text.emit(
		message.format([
			str(enemy_battlers.size())
		])
	)
	await get_tree().create_timer(2).timeout
	party_created.emit(party_battlers)
	calculate_initiative()
	turn_order_created.emit(turn_order)
	#turn_order.append_array(party_battlers)
	#turn_order.append_array(enemy_battlers)
	
	
	print("Battle started!")
	
	start_turn()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	battle_state = BattleState.START

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
func create_party_battlers() -> void:
	for member in party.members:
		var battler := create_party_battler(member)
		party_battlers.append(battler)
func create_party_battler(state: CharacterState) -> Battler:
	var battler := Battler.new()
	battler.name = state.definition.character_name
	battler.max_hp = state.definition.base_stats.max_HP
	battler.current_hp = battler.max_hp
	battler.STR = state.definition.base_stats.STR
	battler.DEX = state.definition.base_stats.DEX
	battler.DEF = state.definition.base_stats.DEF
	battler.LUC = state.definition.base_stats.LUC
	battler.LVL = state.definition.base_stats.LVL
	battler_hp_changed.emit(battler)
	return battler
	
func create_enemy_battler(enemy_data: EnemyData) -> Battler:
	var battler := Battler.new()
	battler.name = enemy_data.enemy_name
	battler.max_hp = enemy_data.stats.max_HP
	battler.current_hp = battler.max_hp
	battler.STR = enemy_data.stats.STR
	battler.DEX = enemy_data.stats.DEX
	battler.DEF = enemy_data.stats.DEF
	battler.LUC = enemy_data.stats.LUC
	battler.LVL = enemy_data.stats.LVL
	return battler
func create_enemy_battlers():
	for data in encounter.enemies:
		var battler := create_enemy_battler(data)
		enemy_battlers.append(battler)
func start_turn() -> void:
	var battler := turn_order[current_turn_index]
	
	if party_battlers.has(battler):
		start_party_turn(battler)
	elif enemy_battlers.has(battler):
		start_enemy_turn(battler)
		
		
func party_attack(attacker: Battler, type: String) -> void:
	var target := get_first_alive_enemy()
	var damage := attacker.STR
	if target == null:
		return
	if type == "normal":
		damage = damage
	else:
		damage = damage*2
	target.take_damage(damage)
	
	print(attacker.name, " attacks ", target.name, "!")
	print(target.name, " HP: ", target.current_hp)
	
	var message := "{0} hit {1} for {2} damage!"
	update_message_text.emit(
		message.format([
			attacker.name,
			target.name,
			str(damage)
		])
	)
	
	if not target.is_alive():
		print(target.name, " was defeated!")
	
	if no_enemies_alive():
		await get_tree().create_timer(0.5).timeout
		end_battle(true)
		return
	
	await get_tree().create_timer(0.5).timeout
	advance_turn()
func enemy_attack(attacker: Battler) -> void:
	var target := get_random_alive_party_member()
	
	if target == null:
		return
	
	var damage := attacker.STR
	
	target.take_damage(damage)
	battler_hp_changed.emit(target)
	print(attacker.name, " attacks ", target.name, "!")
	print(target.name, " HP: ", target.current_hp)
	
	var message := "{0} hit {1} for {2} damage!"
	update_message_text.emit(
		message.format([
			attacker.name,
			target.name,
			str(damage)
		])
	)
	if not target.is_alive():
		print(target.name, " was defeated!")
	
	if no_party_members_alive():
		end_battle(false)
		return
	
	await get_tree().create_timer(0.5).timeout
	advance_turn()
func advance_turn() -> void:
	var attempts := 0
	
	while attempts < turn_order.size():
		current_turn_index += 1
		
		if current_turn_index >= turn_order.size():
			current_turn_index = 0
		
		var next_battler := turn_order[current_turn_index]
		
		if next_battler.is_alive():
			await get_tree().create_timer(0.5).timeout
			start_turn()
			return
		
		attempts += 1
func end_battle(player_won: bool) -> void:
	if player_won:
		battle_state = BattleState.VICTORY
		print("Victory!")
		update_message_text.emit("You won!")
		await get_tree().create_timer(0.5).timeout
		exit_to_dungeon()
	else:
		battle_state = BattleState.DEFEAT
		print("Defeat...")
		update_message_text.emit("You lost...")
		await get_tree().create_timer(0.5).timeout
		exit_to_dungeon()

func exit_to_dungeon():
	await Fade.fade_out(1,Color(1,1,1,1)).finished
	get_tree().change_scene_to_file("uid://hi10d8yc4oxf")
	Fade.fade_in(1,Color(1,1,1,1))
	


func _on_attack_button_pressed() -> void:
	var battler := turn_order[current_turn_index]
	
	if party_battlers.has(battler):
		party_attack(battler, "normal")
func _on_strong_attack_button_pressed() -> void:
	var battler := turn_order[current_turn_index]
	
	if party_battlers.has(battler):
		party_attack(battler, "Strong")
func start_party_turn(battler: Battler) -> void:
	battle_state = BattleState.PLAYER_TURN
	print(battler.name, "'s turn!")
	update_message_text.emit(battler.name + "'s turn!")
	
func start_enemy_turn(battler: Battler) -> void:
	battle_state = BattleState.ENEMY_TURN
	print(battler.name, "'s turn!")
	enemy_attack(battler)
func get_first_alive_enemy() -> Battler:
	for battler in enemy_battlers:
		if battler.is_alive():
			return battler
	
	return null
func get_random_alive_party_member() -> Battler:
	var alive_members: Array[Battler] = []
	
	for battler in party_battlers:
		if battler.is_alive():
			alive_members.append(battler)
	
	if alive_members.is_empty():
		return null
	
	return alive_members.pick_random()
func no_enemies_alive() -> bool:
	for battler in enemy_battlers:
		if battler.is_alive():
			return false
	
	return true
func no_party_members_alive() -> bool:
	for battler in party_battlers:
		if battler.is_alive():
			return false
	
	return true
func calculate_initiative() -> void:
	initial_turn_order.clear()
	turn_order.clear()
	
	initial_turn_order.append_array(party_battlers)
	initial_turn_order.append_array(enemy_battlers)
	
	initial_turn_order.sort_custom(compare_initiative)
	
	turn_order = initial_turn_order.duplicate()
func compare_initiative(a: Battler, b: Battler) -> bool:
	return a.DEX > b.DEX

func start_command_phase() -> void:
	battle_state = BattleState.COMMAND
	
	planned_actions.clear()
	
	print("Command phase started!")
