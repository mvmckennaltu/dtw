extends Node3D
enum BattleState {
	START,
	PLAYER_TURN,
	ENEMY_TURN,
	VICTORY,
	DEFEAT
}
@export var player_data: CharacterData
@export var enemy_data: EnemyData
var turn_order: Array[Battler]
var current_turn_index := 0
var player: Battler
var enemy: Battler
var battle_state : BattleState
signal send_current_hp(value: int)
signal send_max_hp(value: int)
signal update_message_text(message: String)
func start_battle() -> void:
	player = create_player_battler()
	enemy = create_enemy_battler()
	var enemy_message_temp = "{0} is ready to fight!"
	update_message_text.emit(enemy_message_temp.format([enemy.name]))
	print("Battle started!")
	print("Player HP: ", player.current_hp)
	print("Enemy HP: ", enemy.current_hp)
	turn_order = [
	player,
	enemy
]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	battle_state = BattleState.START

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
func create_player_battler() -> Battler:
	var battler := Battler.new()
	battler.max_hp = player_data.base_stats.max_HP
	battler.current_hp = battler.max_hp
	battler.STR = player_data.base_stats.STR
	battler.DEX = player_data.base_stats.DEX
	battler.DEF = player_data.base_stats.DEF
	battler.LUC = player_data.base_stats.LUC
	battler.LVL = player_data.base_stats.LVL
	send_current_hp.emit(battler.current_hp)
	send_max_hp.emit(battler.max_hp)
	return battler
	
func create_enemy_battler() -> Battler:
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
func start_turn() -> void:
	var battler := turn_order[current_turn_index]
	if battler == player:
		return
	else:
		enemy_attack()
		
		
func player_attack() -> void:
	var damage := player.STR
	enemy.take_damage(damage)
	print("Player attacks!")
	print("Enemy HP: ", enemy.current_hp)
	var enemy_hp_string = "You hit {0} for {1} damage!"
	update_message_text.emit(enemy_hp_string.format([enemy.name, str(damage)]))
	if not enemy.is_alive():
		end_battle(true)
		return
	await get_tree().create_timer(0.5).timeout
	advance_turn()
	
func enemy_attack() -> void:
	var damage := enemy.STR
	player.take_damage(damage)
	print("Enemy attacks!")
	print("Player HP: ", player.current_hp)
	var player_hp_string = "{0} hit you for {1} damage!"
	update_message_text.emit(player_hp_string.format([enemy.name, str(damage)]))
	send_current_hp.emit(player.current_hp)
	if not player.is_alive():
		end_battle(false)
		return
	advance_turn()
	
func advance_turn() -> void:
	current_turn_index += 1
	if current_turn_index >= turn_order.size():
		current_turn_index = 0
	await get_tree().create_timer(0.5).timeout
	start_turn()
	
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
	if battler == player:
		player_attack()
