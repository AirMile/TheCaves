extends Node

# Unified input manager for keyboard and controller input
# Performance-optimized with cached vectors

var movement_vector: Vector2 = Vector2.ZERO
var is_dashing: bool = false
var abilities_pressed: Array[bool] = [false, false, false, false]

func _ready():
	print("InputManager initialized")

func _input(event: InputEvent):
	# Handle debug toggle immediately
	if event.is_action_pressed("debug_toggle"):
		EventBus.debug_panel_toggled.emit(not get_viewport().get_children().any(func(node): return node.name == "DebugPanel" and node.visible))

func _process(_delta: float):
	# Cache movement vector for performance
	movement_vector = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()
	
	# Cache dash state
	is_dashing = Input.is_action_just_pressed("dash")
	
	# Cache ability states
	abilities_pressed[0] = Input.is_action_just_pressed("ability_1")
	abilities_pressed[1] = Input.is_action_just_pressed("ability_2") 
	abilities_pressed[2] = Input.is_action_just_pressed("ability_3")
	abilities_pressed[3] = Input.is_action_just_pressed("ability_4")

func get_movement_vector() -> Vector2:
	return movement_vector

func is_dash_pressed() -> bool:
	return is_dashing

func is_ability_pressed(ability_index: int) -> bool:
	if ability_index < 0 or ability_index >= abilities_pressed.size():
		return false
	return abilities_pressed[ability_index]