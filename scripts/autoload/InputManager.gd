extends Node
## Centralized input management for keyboard, mouse, and controller
## Provides unified input handling and validation

# Input state tracking
var movement_vector: Vector2 = Vector2.ZERO
var is_dashing: bool = false
var dash_cooldown_timer: float = 0.0

# Input settings
const DASH_COOLDOWN: float = 1.0
const DEADZONE_THRESHOLD: float = 0.1

# Input validation
var _last_frame_inputs: Dictionary = {}
var _input_spam_threshold: int = 60  # Max inputs per second

func _ready():
	# Ensure input map actions exist
	_validate_input_actions()

func _input(event: InputEvent):
	# Basic input validation to prevent spam
	if not _is_input_valid(event):
		return
		
	# Store for spam detection
	var current_frame = Engine.get_process_frames()
	_last_frame_inputs[event.get_class()] = current_frame

func _process(delta: float):
	_update_movement_input()
	_update_dash_input(delta)

func _validate_input_actions():
	var required_actions = [
		"move_left", "move_right", "move_up", "move_down", 
		"dash", "debug_toggle"
	]
	
	for action in required_actions:
		if not InputMap.has_action(action):
			push_warning("InputManager: Missing input action: " + action)

func _is_input_valid(event: InputEvent) -> bool:
	# Prevent input spam
	var current_frame = Engine.get_process_frames()
	var event_class = event.get_class()
	
	if event_class in _last_frame_inputs:
		var frame_diff = current_frame - _last_frame_inputs[event_class]
		if frame_diff < 1:  # Same frame
			return false
	
	# Validate event types
	if not (event is InputEventKey or event is InputEventMouseButton or 
	        event is InputEventJoypadButton or event is InputEventJoypadMotion):
		return false
	
	return true

func _update_movement_input():
	# Get raw input with validation
	var raw_input = Vector2.ZERO
	
	if _is_action_valid("move_right"):
		raw_input.x += Input.get_action_strength("move_right")
	if _is_action_valid("move_left"):
		raw_input.x -= Input.get_action_strength("move_left")
	if _is_action_valid("move_down"):
		raw_input.y += Input.get_action_strength("move_down")  
	if _is_action_valid("move_up"):
		raw_input.y -= Input.get_action_strength("move_up")
	
	# Apply deadzone and normalize
	if raw_input.length_squared() > DEADZONE_THRESHOLD * DEADZONE_THRESHOLD:
		movement_vector = raw_input.normalized()
	else:
		movement_vector = Vector2.ZERO

func _update_dash_input(delta: float):
	# Update dash cooldown
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta
	
	# Check dash input with validation and cooldown
	if _is_action_valid("dash") and Input.is_action_just_pressed("dash"):
		if dash_cooldown_timer <= 0.0:
			is_dashing = true
			dash_cooldown_timer = DASH_COOLDOWN
		else:
			# Could emit signal for UI feedback about cooldown
			pass

func _is_action_valid(action: String) -> bool:
	return InputMap.has_action(action)

# Public interface with validation
func get_movement_vector() -> Vector2:
	return movement_vector

func get_dash_input() -> bool:
	var result = is_dashing
	is_dashing = false  # Reset after reading
	return result

func is_dash_on_cooldown() -> bool:
	return dash_cooldown_timer > 0.0

func get_dash_cooldown_remaining() -> float:
	return max(0.0, dash_cooldown_timer)

# Debug input handling
func is_debug_toggle_pressed() -> bool:
	return _is_action_valid("debug_toggle") and Input.is_action_just_pressed("debug_toggle")