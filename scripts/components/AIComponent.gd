extends Node
class_name AIComponent

enum DetailLevel { HIGH, MEDIUM, LOW, MINIMAL }

signal target_acquired(target: Node2D)
signal target_lost
signal behavior_changed(new_behavior: String)

@export var detection_range: float = 400.0
@export var attack_range: float = 100.0
@export var behavior: String = "chase"
@export var update_frequency: float = 0.1

var current_target: Node2D
var current_lod: DetailLevel = DetailLevel.HIGH
var last_known_target_position: Vector2
var behavior_timer: float = 0.0
var update_timer: float = 0.0
var is_active: bool = true

@onready var parent_entity: Node2D
@onready var movement_component: MovementComponent
@onready var stats_component: StatsComponent

var player_reference: Node2D

func _ready():
	parent_entity = get_parent() as Node2D
	movement_component = parent_entity.get_node("MovementComponent") as MovementComponent
	stats_component = parent_entity.get_node("StatsComponent") as StatsComponent
	
	call_deferred("_find_player_reference")

func _find_player_reference():
	var player_nodes = get_tree().get_nodes_in_group("player")
	if player_nodes.size() > 0:
		player_reference = player_nodes[0]

func _physics_process(delta: float):
	if not is_active or not parent_entity:
		return
	
	update_timer += delta
	if update_timer < update_frequency:
		return
	
	_update_lod()
	_update_ai_behavior(delta)
	
	update_timer = 0.0

func _update_lod():
	if not player_reference:
		current_lod = DetailLevel.MINIMAL
		return
	
	var distance_sq = parent_entity.global_position.distance_squared_to(player_reference.global_position)
	
	if distance_sq < 90000:      # 300px
		current_lod = DetailLevel.HIGH
	elif distance_sq < 360000:   # 600px
		current_lod = DetailLevel.MEDIUM  
	elif distance_sq < 810000:   # 900px
		current_lod = DetailLevel.LOW
	else:
		current_lod = DetailLevel.MINIMAL

func _update_ai_behavior(delta: float):
	match current_lod:
		DetailLevel.HIGH:
			_full_ai_update(delta)
		DetailLevel.MEDIUM:
			_simple_ai_update(delta)
		DetailLevel.LOW:
			_basic_movement_update(delta)
		DetailLevel.MINIMAL:
			_minimal_update(delta)

func _full_ai_update(delta: float):
	_scan_for_targets()
	_execute_behavior(delta)
	behavior_timer += delta

func _simple_ai_update(delta: float):
	if current_target:
		_execute_simple_behavior(delta)
	else:
		_scan_for_targets()

func _basic_movement_update(delta: float):
	if current_target:
		_move_toward_target()

func _minimal_update(delta: float):
	pass

func _scan_for_targets():
	if not player_reference:
		return
	
	var distance_to_player = parent_entity.global_position.distance_to(player_reference.global_position)
	
	if distance_to_player <= detection_range:
		if current_target != player_reference:
			current_target = player_reference
			last_known_target_position = current_target.global_position
			target_acquired.emit(current_target)
	else:
		if current_target:
			current_target = null
			target_lost.emit()

func _execute_behavior(delta: float):
	if not current_target:
		_idle_behavior(delta)
		return
	
	last_known_target_position = current_target.global_position
	
	match behavior:
		"chase":
			_chase_behavior(delta)
		"ranged":
			_ranged_behavior(delta)
		"tank":
			_tank_behavior(delta)
		"patrol":
			_patrol_behavior(delta)
		_:
			_chase_behavior(delta)

func _execute_simple_behavior(delta: float):
	if current_target:
		_move_toward_target()

func _chase_behavior(delta: float):
	_move_toward_target()

func _ranged_behavior(delta: float):
	var distance_to_target = parent_entity.global_position.distance_to(current_target.global_position)
	
	if distance_to_target > attack_range * 1.2:
		_move_toward_target()
	elif distance_to_target < attack_range * 0.8:
		_move_away_from_target()
	else:
		_stop_movement()

func _tank_behavior(delta: float):
	_move_toward_target()

func _patrol_behavior(delta: float):
	_move_toward_target()

func _idle_behavior(delta: float):
	if last_known_target_position != Vector2.ZERO:
		var direction = (last_known_target_position - parent_entity.global_position).normalized()
		if movement_component:
			movement_component.set_input_direction(direction * 0.3)
	else:
		_stop_movement()

func _move_toward_target():
	if not current_target or not movement_component:
		return
	
	var direction = (current_target.global_position - parent_entity.global_position).normalized()
	movement_component.set_input_direction(direction)

func _move_away_from_target():
	if not current_target or not movement_component:
		return
	
	var direction = (parent_entity.global_position - current_target.global_position).normalized()
	movement_component.set_input_direction(direction)

func _stop_movement():
	if movement_component:
		movement_component.set_input_direction(Vector2.ZERO)

func set_behavior(new_behavior: String):
	if behavior != new_behavior:
		behavior = new_behavior
		behavior_timer = 0.0
		behavior_changed.emit(new_behavior)

func set_active(active: bool):
	is_active = active
	if not is_active:
		_stop_movement()

func get_current_target() -> Node2D:
	return current_target

func get_distance_to_target() -> float:
	if current_target:
		return parent_entity.global_position.distance_to(current_target.global_position)
	return -1.0

func is_target_in_attack_range() -> bool:
	var distance = get_distance_to_target()
	return distance >= 0.0 and distance <= attack_range

func is_target_in_detection_range() -> bool:
	var distance = get_distance_to_target()
	return distance >= 0.0 and distance <= detection_range

func get_current_lod() -> DetailLevel:
	return current_lod

func force_target(target: Node2D):
	current_target = target
	if target:
		last_known_target_position = target.global_position
		target_acquired.emit(target)
	else:
		target_lost.emit()

func clear_target():
	current_target = null
	target_lost.emit()

func get_ai_stats() -> Dictionary:
	return {
		"behavior": behavior,
		"current_lod": DetailLevel.keys()[current_lod],
		"has_target": current_target != null,
		"distance_to_target": get_distance_to_target(),
		"in_attack_range": is_target_in_attack_range(),
		"in_detection_range": is_target_in_detection_range(),
		"is_active": is_active
	}