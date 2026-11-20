extends CharacterBody3D
class_name DungeonEnemy
var state: EnemyState = EnemyState.IDLE
const SPEED = 5.0
@export var patrol_a : Node3D
@export var patrol_b : Node3D
@onready var nav = $NavigationAgent3D
var player: CharacterBody3D
var chosen_target : String
var patrol_target_position : Vector3
enum EnemyState {
	CHASE,
	IDLE
}
func _ready():
	if patrol_a != null:
		patrol_target_position = patrol_a.global_position
		chosen_target = "A"

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	match state:
		EnemyState.IDLE:
			update_idle(delta)
		EnemyState.CHASE:
			update_chase(delta)
	

	move_and_slide()

func update_idle(delta: float):
	if patrol_a && patrol_b != null:
		var patrol_a_distance = (patrol_a.global_position - global_position)
		var patrol_b_distance = (patrol_b.global_position - global_position)
		if nav.is_navigation_finished():
			
			if chosen_target == "B":
				velocity.x = 0
				velocity.y = 0
				await get_tree().create_timer(1.25).timeout
				nav.target_position = patrol_a.global_position
				chosen_target = "A"
			else: 
				velocity.x = 0
				velocity.z = 0
				await get_tree().create_timer(1.25).timeout
				nav.target_position = patrol_b.global_position
				chosen_target = "B"
	var next = nav.get_next_path_position()
	var direction = next - global_position
	direction.y = 0
	if direction.length() > 0.01:
		look_at(global_position - direction, Vector3.UP)
	direction = direction.normalized()
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED
	if player:
		state = EnemyState.CHASE
	
func update_chase(delta):
	print("chasing")
	if player == null:
		print("player is null")
		state = EnemyState.IDLE
		return
	nav.target_position = player.global_position
	if nav.is_navigation_finished():
		print("nav finished")
		velocity.x = 0
		velocity.z = 0
		return
	var next = nav.get_next_path_position()
	var direction = next - global_position
	direction.y = 0
	if direction.length() > 0.01:
		look_at(global_position - direction, Vector3.UP)
	direction = direction.normalized()
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED

func _on_sight_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player = body
		state = EnemyState.CHASE
func _on_sight_range_body_exited(body: Node3D) -> void:
	if body == player:
		player = null
		velocity.x = 0
		velocity.z = 0
		state = EnemyState.IDLE
