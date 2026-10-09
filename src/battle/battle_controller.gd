extends Node3D
class_name BattleController
enum BattleState {
	START,
	PLAYER_TURN,
	ENEMY_TURN,
	VICTORY,
	DEFEAT,
	COMMAND,
	RESOLUTION
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
@onready var battle_menu : BattleMenuController = $"../CanvasLayer/BattleMenuControl"

var party_battlers: Array[Battler] = []
var enemy_battlers: Array[Battler] = []
var initial_turn_order: Array[Battler] = []
var battle_state: BattleState
signal send_current_hp(value: int)
signal send_max_hp(value: int)
signal battler_hp_changed(battler: Battler)
signal battler_sp_changed(battler: Battler)
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
	
	party_created.emit(party_battlers)
	calculate_initiative()
	turn_order_created.emit(turn_order)
	#turn_order.append_array(party_battlers)
	#turn_order.append_array(enemy_battlers)
	
	await get_tree().create_timer(2).timeout
	print("Battle started!")
	start_command_phase()
	#start_turn()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	battle_state = BattleState.START
	if battle_menu != null:
		battle_menu.battle_start.connect(start_battle_button_pressed)
		battle_menu.all_attack.connect(set_all_actions_to_attack)
	else:
		print("Could not get battle menu!")

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
	battler.max_sp = state.definition.base_stats.max_SP
	battler.current_sp = battler.max_sp
	battler.STR = state.definition.base_stats.STR
	battler.DEX = state.definition.base_stats.DEX
	battler.DEF = state.definition.base_stats.DEF
	battler.LUC = state.definition.base_stats.LUC
	battler.LVL = state.definition.base_stats.LVL
	battler_hp_changed.emit(battler)
	battler_sp_changed.emit(battler)
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
	var battler :Battler = get_current_command_battler()
	
	if battler == null:
		return
	
	queue_action(battler, ActionType.NORMAL_ATTACK)
func _on_strong_attack_button_pressed() -> void:
	var battler :Battler = get_current_command_battler()
	
	if battler == null:
		return
	
	queue_action(battler, ActionType.STRONG_ATTACK)
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

func get_current_command_battler() -> Battler:
	for battler in party_battlers:
		if not battler.is_alive():
			continue

		if not planned_actions.has(battler):
			return battler

	return null
func queue_action(
	battler: Battler,
	action: ActionType
) -> void:
	if not party_battlers.has(battler):
		return
	
	if not battler.is_alive():
		return
	
	planned_actions[battler] = action
	
	print(
		battler.name,
		" queued action: ",
		action
	)
func all_party_actions_selected() -> bool:
	for battler in party_battlers:
		if battler.is_alive() and not planned_actions.has(battler):
			return false
	
	return true
func start_battle_button_pressed() -> void:
	if not all_party_actions_selected():
		print("Not everyone has selected an action!")
		update_message_text.emit("Not everyone has selected an action!")
		return
	
	start_resolution_phase()
func choose_enemy_actions() -> void:
	for enemy in enemy_battlers:
		if enemy.is_alive():
			planned_actions[enemy] = ActionType.NORMAL_ATTACK

func start_resolution_phase() -> void:
	choose_enemy_actions()
	
	battle_state = BattleState.RESOLUTION
	
	current_turn_index = 0
	
	print("Resolution phase started!")
	resolve_next_action()
func resolve_next_action() -> void:
	if current_turn_index >= turn_order.size():
		end_round()
		return
	
	var battler := turn_order[current_turn_index]
	
	if not battler.is_alive():
		advance_resolution_turn()
		return
	
	var action = planned_actions.get(battler)
	
	if action == null:
		# Shouldn't happen, but protects us from bad state.
		advance_resolution_turn()
		return
	
	await execute_action(battler, action)
	
	if no_enemies_alive():
		end_battle(true)
		return
	
	if no_party_members_alive():
		end_battle(false)
		return
	
	advance_resolution_turn()
func end_round() -> void:
	print("Round ended!")
	
	planned_actions.clear()
	
	# For now, simply calculate a new initiative order.
	calculate_initiative()
	turn_order_created.emit(turn_order)
	
	start_command_phase()
	
func advance_resolution_turn() -> void:
	current_turn_index += 1
	
	if current_turn_index >= turn_order.size():
		end_round()
	else:
		resolve_next_action()
func execute_action(
	battler: Battler,
	action: ActionType
) -> void:
	match action:
		ActionType.NORMAL_ATTACK:
			await execute_attack(battler, 1.0)
		
		ActionType.STRONG_ATTACK:
			await execute_attack(battler, 2.0)
func execute_attack(
	attacker: Battler,
	damage_multiplier: float
) -> void:
	var target: Battler
	
	if party_battlers.has(attacker):
		target = get_first_alive_enemy()
	else:
		target = get_random_alive_party_member()
	
	if target == null:
		return
	
	var damage := int(attacker.STR * damage_multiplier)
	
	target.take_damage(damage)
	
	battler_hp_changed.emit(target)
	
	print(
		attacker.name,
		" attacks ",
		target.name,
		" for ",
		damage,
		" damage!"
	)
	
	var message := "{0} hit {1} for {2} damage!"
	
	update_message_text.emit(
		message.format([
			attacker.name,
			target.name,
			str(damage)
		])
	)
	
	await get_tree().create_timer(0.5).timeout


func swap_party_members(first: Battler, second: Battler) -> void:
	if battle_state != BattleState.COMMAND:
		return

	if first == second:
		return
	if not party_battlers.has(first):
		return
	if not party_battlers.has(second):
		return

	var first_index := turn_order.find(first)
	var second_index := turn_order.find(second)

	if first_index == -1 or second_index == -1:
		return

	# Find their positions in the original initiative order.
	var initial_first_index := initial_turn_order.find(first)
	var initial_second_index := initial_turn_order.find(second)

	if initial_first_index == -1 or initial_second_index == -1:
		return

	# Identify the faster and slower party members.
	var faster: Battler = first
	var slower: Battler = second

	if second.DEX > first.DEX:
		faster = second
		slower = first

	# Find enemies originally between the two party members
	# whose DEX is between their DEX values.
	var constrained_enemies: Array[Battler] = []

	var start_index: int = mini(
		initial_first_index,
		initial_second_index
	)
	var end_index: int = maxi(
		initial_first_index,
		initial_second_index
	)

	for i in range(start_index + 1, end_index):
		var candidate: Battler = initial_turn_order[i]

		if (
			enemy_battlers.has(candidate)
			and candidate.is_alive()
			and candidate.DEX > slower.DEX
			and candidate.DEX < faster.DEX
		):
			constrained_enemies.append(candidate)

	# Swap the two party members.
	turn_order[first_index] = second
	turn_order[second_index] = first

	# Remove the constrained enemies before reinserting them.
	for enemy in constrained_enemies:
		turn_order.erase(enemy)

	# Place those enemies immediately before the earlier
	# of the two party members in the resulting order.
	var new_first_index := turn_order.find(first)
	var new_second_index := turn_order.find(second)
	var insert_index := mini(new_first_index, new_second_index)

	for i in range(constrained_enemies.size()):
		turn_order.insert(
			insert_index + i,
			constrained_enemies[i]
		)

	turn_order_changed.emit(turn_order)



func enforce_enemy_initiative_constraints() -> void:
	for party_member in party_battlers:
		if not party_member.is_alive():
			continue

		# Keep moving this member right while a faster enemy
		# still appears after them in the order.
		while true:
			var member_index := turn_order.find(party_member)
			var faster_enemy_index := -1

			for i in range(member_index + 1, turn_order.size()):
				var candidate: Battler = turn_order[i]

				if (
					enemy_battlers.has(candidate)
					and candidate.is_alive()
					and candidate.DEX > party_member.DEX
				):
					faster_enemy_index = i
					break

			# No faster enemy remains after this party member.
			if faster_enemy_index == -1:
				break

			# Remove the party member and insert them just after
			# the faster enemy that was blocking them.
			turn_order.remove_at(member_index)
			turn_order.insert(faster_enemy_index, party_member)
func set_all_actions_to_attack():
	for battler in party_battlers:
		queue_action(battler, ActionType.NORMAL_ATTACK)
