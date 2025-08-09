extends CharacterBody2D

# Player controller with null safety and performance optimization

const SPEED: float = 300.0
const DASH_SPEED: float = 600.0
const DASH_DURATION: float = 0.2

var health: int = 100
var max_health: int = 100
var is_dashing: bool = false
var dash_timer: float = 0.0

# Component references (with null safety)
@onready var movement_component = null  # Will be added when component system exists
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready():
	print("Player initializing...")
	
	# Wait for autoloads to be ready
	await get_tree().process_frame
	
	# Verify critical autoloads with proper error handling
	if not InputManager:
		push_error("Player: InputManager autoload not found! Check project.godot autoload settings.")
		set_physics_process(false)
		return
	
	if not EventBus:
		push_error("Player: EventBus autoload not found! Check project.godot autoload settings.")
		return
		
	# Setup collision layers
	collision_layer = 2  # Player layer
	collision_mask = 1   # Walls only (enemies handle collision with player)
	
	# Add to group for identification
	add_to_group("player")
	
	print("Player initialized successfully")

func _physics_process(delta: float):
	# Null safety check for InputManager
	if not InputManager:
		push_error("Player: InputManager became null during gameplay!")
		return
	
	_handle_movement_input(delta)
	_handle_dash_input(delta)
	_update_dash_timer(delta)
	
	# Move with collision detection
	move_and_slide()
	
	# Emit position for other systems (performance: only when moved)
	if velocity != Vector2.ZERO:
		EventBus.player_position_changed.emit(global_position)

func _handle_movement_input(delta: float):
	# Additional null check with error message
	if not InputManager:
		push_error("Player._handle_movement_input: InputManager is null")
		return
	
	# Get validated movement input
	var movement_input = InputManager.get_movement_vector()
	
	# Apply movement speed
	if is_dashing:
		velocity = movement_input * DASH_SPEED
	else:
		velocity = movement_input * SPEED

func _handle_dash_input(delta: float):
	if not InputManager:
		return
		
	if InputManager.is_dash_pressed() and not is_dashing:
		_start_dash()

func _start_dash():
	is_dashing = true
	dash_timer = DASH_DURATION
	print("Dash started")

func _update_dash_timer(delta: float):
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
			print("Dash ended")

func take_damage(amount: int):
	health = max(0, health - amount)
	EventBus.player_health_changed.emit(health)
	
	if health <= 0:
		_die()

func _die():
	print("Player died")
	EventBus.player_died.emit()
	
	# Disable physics but keep node for respawn
	set_physics_process(false)

func heal(amount: int):
	health = min(max_health, health + amount)
	EventBus.player_health_changed.emit(health)

# For debugging and testing
func get_debug_info() -> Dictionary:
	return {
		"position": global_position,
		"velocity": velocity,
		"health": health,
		"is_dashing": is_dashing,
		"input_manager_valid": InputManager != null
	}