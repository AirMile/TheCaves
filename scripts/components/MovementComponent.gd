extends Node
class_name MovementComponent
## Physics-based movement component with dash mechanics
## Optimized for performance with CharacterBody2D

signal movement_state_changed(is_moving: bool)
signal dash_started
signal dash_ended

@export var base_speed: float = 200.0
@export var dash_speed: float = 400.0
@export var dash_duration: float = 0.2
@export var friction: float = 800.0
@export var acceleration: float = 1600.0

# Movement state
var current_speed: float
var speed_multiplier: float = 1.0
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO

# Parent references (cached for performance)
var parent_body: CharacterBody2D
var was_moving: bool = false

func _ready():
	parent_body = get_parent() as CharacterBody2D
	if not parent_body:
		push_error("MovementComponent: Parent must be CharacterBody2D")
		return
	
	current_speed = base_speed
	
	# Validate configuration
	if base_speed <= 0:
		push_error("MovementComponent: base_speed must be positive")
		base_speed = 100.0
	
	if dash_speed <= base_speed:
		push_warning("MovementComponent: dash_speed should be greater than base_speed")

func _physics_process(delta: float):
	if not parent_body:
		return
	
	_update_dash_state(delta)
	_update_movement_state()

func move_towards(target_position: Vector2, delta: float):
	if not parent_body:
		return
	
	var direction = (target_position - parent_body.global_position).normalized()
	apply_movement_input(direction, delta)

func apply_movement_input(input_direction: Vector2, delta: float):
	if not parent_body:
		return
	
	# Normalize input to prevent faster diagonal movement
	if input_direction.length_squared() > 1.0:
		input_direction = input_direction.normalized()
	
	var target_velocity: Vector2
	var effective_speed = current_speed * speed_multiplier
	
	if is_dashing:
		# During dash, maintain dash direction and speed
		target_velocity = dash_direction * dash_speed
	elif input_direction.length_squared() > 0.01:  # Use squared length to avoid sqrt
		# Apply acceleration towards target velocity
		target_velocity = input_direction * effective_speed
		parent_body.velocity = parent_body.velocity.move_toward(target_velocity, acceleration * delta)
	else:
		# Apply friction when no input
		target_velocity = Vector2.ZERO
		parent_body.velocity = parent_body.velocity.move_toward(target_velocity, friction * delta)
	
	# Apply the movement
	parent_body.move_and_slide()

func start_dash(direction: Vector2) -> bool:
	if not parent_body or is_dashing:
		return false
	
	if direction.length_squared() < 0.01:  # Use squared length
		return false
	
	is_dashing = true
	dash_timer = dash_duration
	dash_direction = direction.normalized()
	
	# Set dash velocity immediately
	parent_body.velocity = dash_direction * dash_speed
	
	dash_started.emit()
	
	# Play dash audio
	if AudioManager:
		AudioManager.play_dash(parent_body.global_position)
	
	return true

func _update_dash_state(delta: float):
	if not is_dashing:
		return
	
	dash_timer -= delta
	if dash_timer <= 0.0:
		is_dashing = false
		dash_ended.emit()

func _update_movement_state():
	var currently_moving = parent_body.velocity.length_squared() > 100.0  # Use squared length
	
	if currently_moving != was_moving:
		movement_state_changed.emit(currently_moving)
		was_moving = currently_moving

# Upgrade system support
func modify_speed(multiplier: float):
	speed_multiplier = maxf(0.1, speed_multiplier * multiplier)  # Prevent negative/zero speed

func add_speed_bonus(bonus: float):
	speed_multiplier = maxf(0.1, speed_multiplier + bonus)

func set_base_speed(new_speed: float):
	if new_speed > 0:
		base_speed = new_speed

# Status effects support
func apply_slow(slow_factor: float, _duration: float):
	# In a full implementation, this would use a timer system
	speed_multiplier *= (1.0 - clampf(slow_factor, 0.0, 0.9))

func clear_status_effects():
	speed_multiplier = 1.0

# Getters with validation
func get_current_speed() -> float:
	return current_speed * speed_multiplier

func get_velocity() -> Vector2:
	return parent_body.velocity if parent_body else Vector2.ZERO

func get_movement_direction() -> Vector2:
	if not parent_body or parent_body.velocity.length_squared() < 1.0:
		return Vector2.ZERO
	return parent_body.velocity.normalized()

func is_moving() -> bool:
	return parent_body and parent_body.velocity.length_squared() > 100.0

func get_dash_remaining() -> float:
	return max(0.0, dash_timer) if is_dashing else 0.0

# Physics configuration helpers
func set_collision_layers(layer: int, mask: int):
	if parent_body:
		parent_body.collision_layer = layer
		parent_body.collision_mask = mask

# Emergency stop for knockbacks or stuns
func force_stop():
	if parent_body:
		parent_body.velocity = Vector2.ZERO
	
	if is_dashing:
		is_dashing = false
		dash_timer = 0.0
		dash_ended.emit()

# Debug information
func get_debug_info() -> Dictionary:
	return {
		"current_speed": get_current_speed(),
		"base_speed": base_speed,
		"speed_multiplier": speed_multiplier,
		"velocity": get_velocity(),
		"velocity_magnitude": get_velocity().length(),
		"is_dashing": is_dashing,
		"dash_remaining": get_dash_remaining(),
		"is_moving": is_moving()
	}