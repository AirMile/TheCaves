extends Node
## Centralized input management for keyboard, mouse, and controller
## Provides unified input handling and validation

# Input state tracking
var movement_vector: Vector2 = Vector2.ZERO

# Input settings
const DEADZONE_THRESHOLD: float = 0.1

# Input validation
var _last_frame_inputs: Dictionary = {}
var _input_spam_threshold: int = 60  # Max inputs per second
var _input_counts: Dictionary = {}  # Track input counts per second

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

func _process(_delta: float):
	_update_movement_input()

func _validate_input_actions():
	var required_actions = [
		"move_left", "move_right", "move_up", "move_down"
	]
	
	for action in required_actions:
		if not InputMap.has_action(action):
			push_warning("InputManager: Missing input action: " + action)

func _is_input_valid(event: InputEvent) -> bool:
	# Validate event types
	if not (event is InputEventKey or event is InputEventMouseButton or 
	        event is InputEventJoypadButton or event is InputEventJoypadMotion):
		return false
	
	# Prevent input spam using threshold
	var current_time = Time.get_unix_time_from_system()
	var event_class = event.get_class()
	
	# Initialize tracking for this event type if needed
	if not event_class in _input_counts:
		_input_counts[event_class] = {"count": 0, "last_reset": current_time}
	
	var event_data = _input_counts[event_class]
	
	# Reset counter every second
	if current_time - event_data.last_reset >= 1.0:
		event_data.count = 0
		event_data.last_reset = current_time
	
	# Check if we've exceeded the spam threshold
	if event_data.count >= _input_spam_threshold:
		return false
	
	# Valid input - increment counter
	event_data.count += 1
	
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


func _is_action_valid(action: String) -> bool:
	return InputMap.has_action(action)

# Public interface with validation
func get_movement_vector() -> Vector2:
	return movement_vector


