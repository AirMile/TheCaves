extends Node
class_name MovementComponent
## Physics-based movement component with dash ability
## Optimized for performance with CharacterBody2D
## Follows official Godot movement patterns

signal movement_state_changed(is_moving: bool)
signal dash_started
signal dash_ended

@export var base_speed: float = 200.0
@export var friction: float = 800.0
@export var acceleration: float = 1600.0

# Dash properties
@export var dash_speed: float = 400.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 1.0

# Movement state
var current_speed: float
var speed_multiplier: float = 1.0

# Dash state
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
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
		push_warning("MovementComponent: dash_speed should be higher than base_speed")
		dash_speed = base_speed * 2.0
	
	if dash_duration <= 0:
		push_error("MovementComponent: dash_duration must be positive")
		dash_duration = 0.2
	
	if dash_cooldown < dash_duration:
		push_warning("MovementComponent: dash_cooldown should be longer than dash_duration")
		dash_cooldown = dash_duration * 2.0

func _physics_process(delta: float):
	if not parent_body:
		return
	
	_update_dash_timers(delta)
	_update_movement_state()

func _update_dash_timers(delta: float):
	# Update dash timer
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			_end_dash()
	
	# Update cooldown timer
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta

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
	
	# Handle dash movement separately
	if is_dashing:
		_apply_dash_movement()
		return
	
	var target_velocity: Vector2
	var effective_speed = current_speed * speed_multiplier
	
	if input_direction.length_squared() > 0.01:  # Use squared length to avoid sqrt
		# Apply acceleration towards target velocity
		target_velocity = input_direction * effective_speed
		parent_body.velocity = parent_body.velocity.move_toward(target_velocity, acceleration * delta)
	else:
		# Apply friction when no input
		target_velocity = Vector2.ZERO
		parent_body.velocity = parent_body.velocity.move_toward(target_velocity, friction * delta)
	
	# Apply the movement using Godot's recommended method
	parent_body.move_and_slide()

func _apply_dash_movement():
	# During dash, maintain constant velocity in dash direction
	parent_body.velocity = dash_direction * dash_speed
	parent_body.move_and_slide()

func start_dash(direction: Vector2) -> bool:
	# Check if dash is available
	if not can_dash():
		return false
	
	# Normalize direction
	if direction.length_squared() < 0.01:
		# Use current movement direction if no direction provided
		if parent_body.velocity.length_squared() > 0.01:
			direction = parent_body.velocity.normalized()
		else:
			# Default to facing right if no movement
			direction = Vector2.RIGHT
	else:
		direction = direction.normalized()
	
	# Start dash
	is_dashing = true
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown
	dash_direction = direction
	
	# Play dash audio
	if AudioManager:
		AudioManager.play_dash(parent_body.global_position)
	
	# Emit signal
	dash_started.emit()
	
	print("MovementComponent: Dash started in direction %s" % direction)
	return true

func _end_dash():
	is_dashing = false
	dash_timer = 0.0
	
	# Emit signal
	dash_ended.emit()
	
	print("MovementComponent: Dash ended")

func can_dash() -> bool:
	return not is_dashing and dash_cooldown_timer <= 0.0

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

# Dash upgrade support
func modify_dash_speed(multiplier: float):
	dash_speed = maxf(base_speed, dash_speed * multiplier)

func modify_dash_duration(multiplier: float):
	dash_duration = maxf(0.1, dash_duration * multiplier)

func modify_dash_cooldown(multiplier: float):
	dash_cooldown = maxf(0.1, dash_cooldown * multiplier)

func set_dash_properties(speed: float, duration: float, cooldown: float):
	if speed > 0:
		dash_speed = speed
	if duration > 0:
		dash_duration = duration
	if cooldown > 0:
		dash_cooldown = cooldown

# Status effects support
func apply_slow(slow_factor: float, _duration: float):
	# In a full implementation, this would use a timer system
	speed_multiplier *= (1.0 - clampf(slow_factor, 0.0, 0.9))

func clear_status_effects():
	speed_multiplier = 1.0

# Getters with validation
func get_current_speed() -> float:
	return current_speed * speed_multiplier

func get_dash_speed() -> float:
	return dash_speed

func get_velocity() -> Vector2:
	return parent_body.velocity if parent_body else Vector2.ZERO

func get_movement_direction() -> Vector2:
	if not parent_body or parent_body.velocity.length_squared() < 1.0:
		return Vector2.ZERO
	return parent_body.velocity.normalized()

func is_moving() -> bool:
	return parent_body and parent_body.velocity.length_squared() > 100.0

func get_dash_cooldown_remaining() -> float:
	return max(0.0, dash_cooldown_timer)

func get_dash_cooldown_percentage() -> float:
	if dash_cooldown <= 0:
		return 0.0
	return get_dash_cooldown_remaining() / dash_cooldown

# Physics configuration helpers
func set_collision_layers(layer: int, mask: int):
	if parent_body:
		parent_body.collision_layer = layer
		parent_body.collision_mask = mask

# Emergency stop for knockbacks or stuns
func force_stop():
	if parent_body:
		parent_body.velocity = Vector2.ZERO
	_end_dash()  # Also stop any active dash

# Debug information
func get_debug_info() -> Dictionary:
	return {
		"current_speed": get_current_speed(),
		"base_speed": base_speed,
		"speed_multiplier": speed_multiplier,
		"velocity": get_velocity(),
		"velocity_magnitude": get_velocity().length(),
		"is_moving": is_moving(),
		"is_dashing": is_dashing,
		"dash_speed": dash_speed,
		"dash_duration": dash_duration,
		"dash_cooldown": dash_cooldown,
		"dash_cooldown_remaining": get_dash_cooldown_remaining(),
		"can_dash": can_dash()
	}