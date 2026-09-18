@tool
extends PhantomCamera3D


const CAMERA_ROTATION_SPEED := 120.0


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	var rotation_change := 0.0

	if Input.is_action_pressed("dungeon_rotate_camera_left"):
		rotation_change += CAMERA_ROTATION_SPEED * delta

	if Input.is_action_pressed("dungeon_rotate_camera_right"):
		rotation_change -= CAMERA_ROTATION_SPEED * delta

	if rotation_change != 0.0:
		var camera_rotation := get_third_person_rotation_degrees()

		camera_rotation.y += rotation_change
		camera_rotation.y = wrapf(camera_rotation.y, 0.0, 360.0)

		set_third_person_rotation_degrees(camera_rotation)
