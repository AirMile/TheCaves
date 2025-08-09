extends Node

var movement_vector: Vector2 = Vector2.ZERO
var dash_pressed: bool = false
var dash_just_pressed: bool = false
var abilities_pressed: Array[bool] = [false, false, false, false]
var abilities_just_pressed: Array[bool] = [false, false, false, false]

var mouse_position: Vector2 = Vector2.ZERO
var world_mouse_position: Vector2 = Vector2.ZERO

var input_disabled: bool = false

@onready var main_camera: Camera2D

func _ready():
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	
	call_deferred("_find_camera")
	
	if OS.is_debug_build():
		print("[InputManager] Initialized - Input system ready")

func _find_camera():
	var camera_nodes = get_tree().get_nodes_in_group("main_camera")
	if camera_nodes.size() > 0:
		main_camera = camera_nodes[0]
	else:
		var viewport = get_viewport()
		if viewport and viewport.get_camera_2d():
			main_camera = viewport.get_camera_2d()

func _process(_delta):
	if input_disabled:
		_reset_inputs()
		return
	
	_update_movement_input()
	_update_action_inputs()
	_update_mouse_input()

func _update_movement_input():
	movement_vector = Vector2.ZERO
	
	if Input.is_action_pressed("move_right"):
		movement_vector.x += 1.0
	if Input.is_action_pressed("move_left"):
		movement_vector.x -= 1.0
	if Input.is_action_pressed("move_down"):
		movement_vector.y += 1.0
	if Input.is_action_pressed("move_up"):
		movement_vector.y -= 1.0
	
	movement_vector = movement_vector.normalized()

func _update_action_inputs():
	dash_just_pressed = Input.is_action_just_pressed("dash")
	dash_pressed = Input.is_action_pressed("dash")
	
	abilities_just_pressed[0] = Input.is_action_just_pressed("ability_1")
	abilities_just_pressed[1] = Input.is_action_just_pressed("ability_2")
	abilities_just_pressed[2] = Input.is_action_just_pressed("ability_3")
	abilities_just_pressed[3] = Input.is_action_just_pressed("ability_4")
	
	abilities_pressed[0] = Input.is_action_pressed("ability_1")
	abilities_pressed[1] = Input.is_action_pressed("ability_2")
	abilities_pressed[2] = Input.is_action_pressed("ability_3")
	abilities_pressed[3] = Input.is_action_pressed("ability_4")
	
	if Input.is_action_just_pressed("debug_toggle"):
		EventBus.debug_toggle_requested.emit()

func _update_mouse_input():
	mouse_position = get_viewport().get_mouse_position()
	
	if main_camera:
		world_mouse_position = main_camera.get_global_mouse_position()
	else:
		world_mouse_position = mouse_position

func get_movement_vector() -> Vector2:
	return movement_vector

func is_dash_pressed() -> bool:
	return dash_pressed

func is_dash_just_pressed() -> bool:
	return dash_just_pressed

func is_ability_pressed(ability_index: int) -> bool:
	if ability_index < 0 or ability_index >= abilities_pressed.size():
		return false
	return abilities_pressed[ability_index]

func is_ability_just_pressed(ability_index: int) -> bool:
	if ability_index < 0 or ability_index >= abilities_just_pressed.size():
		return false
	return abilities_just_pressed[ability_index]

func get_mouse_world_position() -> Vector2:
	return world_mouse_position

func get_mouse_screen_position() -> Vector2:
	return mouse_position

func disable_input():
	input_disabled = true
	_reset_inputs()

func enable_input():
	input_disabled = false

func _reset_inputs():
	movement_vector = Vector2.ZERO
	dash_pressed = false
	dash_just_pressed = false
	for i in range(abilities_pressed.size()):
		abilities_pressed[i] = false
		abilities_just_pressed[i] = false

func get_look_direction_from_player(player_position: Vector2) -> Vector2:
	var direction = (world_mouse_position - player_position).normalized()
	return direction if direction.length() > 0.1 else Vector2.RIGHT