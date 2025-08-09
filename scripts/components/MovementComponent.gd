extends Node
class_name MovementComponent

signal movement_started
signal movement_stopped
signal direction_changed(new_direction: Vector2)

@export var max_speed: float = 200.0
@export var acceleration: float = 800.0
@export var friction: float = 600.0
@export var rotation_speed: float = 8.0
@export var enable_rotation: bool = false

var velocity: Vector2 = Vector2.ZERO
var input_direction: Vector2 = Vector2.ZERO
var target_velocity: Vector2 = Vector2.ZERO
var is_moving: bool = false

@onready var parent_body: CharacterBody2D

func _ready():
	parent_body = get_parent() as CharacterBody2D
	if not parent_body:
		push_error("MovementComponent must be child of CharacterBody2D")

func _physics_process(delta):
	if not parent_body:
		return
	
	_update_target_velocity()
	_apply_movement(delta)
	_handle_rotation(delta)
	_update_movement_state()

func set_input_direction(direction: Vector2):
	var new_direction = direction.normalized() if direction.length() > 0.1 else Vector2.ZERO
	
	if new_direction != input_direction:
		input_direction = new_direction
		direction_changed.emit(input_direction)

func _update_target_velocity():
	target_velocity = input_direction * max_speed

func _apply_movement(delta: float):
	if input_direction.length() > 0.1:
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	parent_body.velocity = velocity
	parent_body.move_and_slide()
	
	velocity = parent_body.velocity

func _handle_rotation(delta: float):
	if not enable_rotation or input_direction.length() < 0.1:
		return
	
	var target_angle = input_direction.angle()
	parent_body.rotation = lerp_angle(parent_body.rotation, target_angle, rotation_speed * delta)

func _update_movement_state():
	var was_moving = is_moving
	is_moving = velocity.length() > 10.0
	
	if is_moving and not was_moving:
		movement_started.emit()
	elif not is_moving and was_moving:
		movement_stopped.emit()

func apply_force(force: Vector2):
	velocity += force

func apply_impulse(impulse: Vector2):
	velocity += impulse

func stop_immediately():
	velocity = Vector2.ZERO
	input_direction = Vector2.ZERO
	target_velocity = Vector2.ZERO
	
	if parent_body:
		parent_body.velocity = Vector2.ZERO

func get_velocity() -> Vector2:
	return velocity

func get_speed() -> float:
	return velocity.length()

func get_input_direction() -> Vector2:
	return input_direction

func is_at_max_speed() -> bool:
	return get_speed() >= max_speed * 0.95

func set_max_speed(new_speed: float):
	max_speed = max(0.0, new_speed)

func modify_speed(multiplier: float):
	max_speed *= max(0.0, multiplier)

func get_normalized_velocity() -> Vector2:
	return velocity.normalized() if velocity.length() > 0.1 else Vector2.ZERO

func face_direction(direction: Vector2):
	if not enable_rotation or not parent_body:
		return
	
	if direction.length() > 0.1:
		parent_body.rotation = direction.angle()

func look_at_position(position: Vector2):
	if not parent_body:
		return
	
	var direction = (position - parent_body.global_position).normalized()
	face_direction(direction)

func get_movement_stats() -> Dictionary:
	return {
		"velocity": velocity,
		"speed": get_speed(),
		"max_speed": max_speed,
		"input_direction": input_direction,
		"is_moving": is_moving,
		"is_at_max_speed": is_at_max_speed()
	}