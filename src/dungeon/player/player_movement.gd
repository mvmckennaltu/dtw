extends CharacterBody3D


@export var walk_speed = 5.0
@export var run_speed = 8.0
var current_speed: float
const CAMERA_ROTATION_SPEED := 120.0
@onready var camera: Camera3D = get_viewport().get_camera_3d()
@onready var _player_pcam: PhantomCamera3D = $PhantomCamera3D

func _ready() -> void:
	#_player_pcam = owner.get_node("$PhantomCamera3D")
	pass
func _physics_process(delta: float) -> void:
# Camera rotation
	var rotation_change := 0.0

	if Input.is_action_pressed("dungeon_rotate_camera_left"):
		rotation_change += CAMERA_ROTATION_SPEED * delta

	if Input.is_action_pressed("dungeon_rotate_camera_right"):
		rotation_change -= CAMERA_ROTATION_SPEED * delta

	if rotation_change != 0.0:
		var camera_rotation = _player_pcam.get_third_person_rotation_degrees()
		camera_rotation.y += rotation_change
		camera_rotation.y = wrapf(camera_rotation.y, 0.0, 360.0)
		_player_pcam.set_third_person_rotation_degrees(camera_rotation)
	var input_dir := Input.get_vector("dungeon_move_left", "dungeon_move_right", "dungeon_move_up", "dungeon_move_down")
	
	var forward := camera.global_transform.basis.z
	var right := camera.global_transform.basis.x

	forward.y = 0
	right.y = 0

	forward = forward.normalized()
	right = right.normalized()

	var direction := (right * input_dir.x + forward * input_dir.y).normalized()
	if Input.is_action_pressed("dungeon_run"):
		current_speed = run_speed
	else:
		current_speed = walk_speed
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
