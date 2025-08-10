extends Node
class_name AIComponent
## LOD-aware enemy AI with staggered updates for performance
## Uses distance_squared_to() and frame-based update distribution

signal target_acquired(target: Node2D)
signal target_lost
signal state_changed(new_state: String)

enum AIState { IDLE, SEEKING, ATTACKING, FLEEING, STUNNED }
enum DetailLevel { HIGH, MEDIUM, LOW, MINIMAL }

@export var detection_range: float = 200.0
@export var attack_range: float = 50.0
@export var base_move_speed: float = 100.0

# LOD distance thresholds (base distances in pixels)
const LOD_DISTANCE_HIGH: float = 300.0
const LOD_DISTANCE_MEDIUM: float = 600.0  
const LOD_DISTANCE_LOW: float = 900.0

# LOD thresholds (pre-calculated squared distances for performance)
const LOD_DISTANCES_SQUARED: Dictionary = {
	DetailLevel.HIGH: LOD_DISTANCE_HIGH * LOD_DISTANCE_HIGH,      # High detail: squared threshold
	DetailLevel.MEDIUM: LOD_DISTANCE_MEDIUM * LOD_DISTANCE_MEDIUM,   # Medium detail: squared threshold
	DetailLevel.LOW: LOD_DISTANCE_LOW * LOD_DISTANCE_LOW,       # Low detail: squared threshold
	# MINIMAL is anything beyond LOW
}

# State management
var current_state: AIState = AIState.IDLE
var current_lod: DetailLevel = DetailLevel.HIGH
var target: Node2D = null

# Performance optimization - staggered updates
var update_group: int = 0
var frames_between_updates: int = 4  # Update 1/4 of enemies each frame

# Cached references for performance
var parent_entity: CharacterBody2D
var movement_component: MovementComponent  
var health_component: HealthComponent
var player_reference: Node2D

# Detection and behavior state
var detection_range_squared: float
var attack_range_squared: float
var last_known_player_position: Vector2
var sight_lost_timer: float = 0.0
var attack_cooldown: float = 0.0

# Staggered update tracking
var last_full_update_frame: int = 0

func _ready():
	# Cache parent references
	parent_entity = get_parent() as CharacterBody2D
	if not parent_entity:
		push_error("AIComponent: Parent must be CharacterBody2D")
		set_physics_process(false)
		return
	
	# Find components
	movement_component = parent_entity.get_node("MovementComponent") as MovementComponent
	health_component = parent_entity.get_node("HealthComponent") as HealthComponent
	
	# Find player reference (cached for performance)
	_find_player_reference()
	
	# Pre-calculate squared distances for performance
	detection_range_squared = detection_range * detection_range
	attack_range_squared = attack_range * attack_range
	
	# Assign to staggered update group
	update_group = parent_entity.get_instance_id() % frames_between_updates

func _physics_process(delta: float):
	if not parent_entity or not player_reference:
		return
	
	# Staggered update system - only update 1/4 of enemies per frame
	var current_frame = Engine.get_physics_frames()
	var should_update = (current_frame % frames_between_updates) == update_group
	
	if should_update:
		# Full AI update with compensated delta
		var compensated_delta = delta * frames_between_updates
		_update_lod()
		_perform_ai_update(compensated_delta)
		last_full_update_frame = current_frame
	else:
		# Only update critical systems every frame
		_update_critical_systems(delta)

func _find_player_reference():
	# Find player in the scene tree
	var player_group = get_tree().get_nodes_in_group("player")
	if player_group.size() > 0:
		player_reference = player_group[0]
	else:
		push_warning("AIComponent: No player found in 'player' group")

func _update_lod():
	if not player_reference:
		return
	
	# Use distance_squared_to for performance (avoids sqrt)
	var distance_squared = parent_entity.global_position.distance_squared_to(player_reference.global_position)
	
	# Determine LOD level
	var new_lod: DetailLevel
	if distance_squared < LOD_DISTANCES_SQUARED[DetailLevel.HIGH]:
		new_lod = DetailLevel.HIGH
	elif distance_squared < LOD_DISTANCES_SQUARED[DetailLevel.MEDIUM]:
		new_lod = DetailLevel.MEDIUM
	elif distance_squared < LOD_DISTANCES_SQUARED[DetailLevel.LOW]:
		new_lod = DetailLevel.LOW
	else:
		new_lod = DetailLevel.MINIMAL
	
	current_lod = new_lod

func _perform_ai_update(delta: float):
	# AI processing based on LOD level
	match current_lod:
		DetailLevel.HIGH:
			_full_ai_update(delta)
		DetailLevel.MEDIUM:
			_medium_ai_update(delta)
		DetailLevel.LOW:
			_basic_ai_update(delta)
		DetailLevel.MINIMAL:
			_minimal_ai_update(delta)

func _update_critical_systems(delta: float):
	# Update cooldowns and timers that need frame-accurate timing
	if attack_cooldown > 0.0:
		attack_cooldown -= delta
	
	if sight_lost_timer > 0.0:
		sight_lost_timer -= delta

func _full_ai_update(delta: float):
	# High detail: Full AI processing with all behaviors
	_update_target_detection()
	_update_state_machine(delta)
	_update_movement(delta)
	_update_attack_behavior(delta)

func _medium_ai_update(delta: float):
	# Medium detail: Basic AI and movement, no complex attack patterns
	_update_target_detection() 
	_update_basic_state_machine(delta)
	_update_movement(delta)

func _basic_ai_update(delta: float):
	# Low detail: Simple movement toward player only
	if _can_see_target():
		_move_toward_target(delta)

func _minimal_ai_update(delta: float):
	# Minimal detail: Position updates only, no AI processing
	pass

func _update_target_detection():
	if not player_reference:
		return
	
	var distance_squared = parent_entity.global_position.distance_squared_to(player_reference.global_position)
	
	if distance_squared <= detection_range_squared:
		if target != player_reference:
			target = player_reference
			target_acquired.emit(target)
		last_known_player_position = player_reference.global_position
		sight_lost_timer = 2.0  # Remember position for 2 seconds
	elif sight_lost_timer <= 0.0 and target:
		target = null
		target_lost.emit()

func _update_state_machine(delta: float):
	var new_state = current_state
	
	match current_state:
		AIState.IDLE:
			if target:
				new_state = AIState.SEEKING
		
		AIState.SEEKING:
			if not target:
				new_state = AIState.IDLE
			elif _is_in_attack_range():
				new_state = AIState.ATTACKING
		
		AIState.ATTACKING:
			if not target:
				new_state = AIState.IDLE
			elif not _is_in_attack_range():
				new_state = AIState.SEEKING
		
		AIState.STUNNED:
			# Exit stun after timer (would be implemented with a timer)
			new_state = AIState.IDLE
	
	if new_state != current_state:
		current_state = new_state
		state_changed.emit(_state_to_string(current_state))

func _update_basic_state_machine(delta: float):
	# Simplified state machine for medium LOD
	if target and _can_see_target():
		current_state = AIState.SEEKING
	else:
		current_state = AIState.IDLE

func _update_movement(delta: float):
	if not movement_component or not target:
		return
	
	match current_state:
		AIState.SEEKING:
			_move_toward_target(delta)
		AIState.ATTACKING:
			if not _is_in_attack_range():
				_move_toward_target(delta)

func _move_toward_target(delta: float):
	if not movement_component or not target:
		return
	
	var target_position = target.global_position
	movement_component.move_towards(target_position, delta)

func _update_attack_behavior(delta: float):
	if current_state != AIState.ATTACKING or attack_cooldown > 0.0:
		return
	
	if _is_in_attack_range():
		_perform_attack()
		attack_cooldown = 1.0  # 1 second attack cooldown

func _perform_attack():
	# Placeholder for attack logic - would trigger weapon systems
	if AudioManager:
		AudioManager.play_enemy_hit(parent_entity.global_position)

func _can_see_target() -> bool:
	return target != null and is_instance_valid(target)

func _is_in_attack_range() -> bool:
	if not target:
		return false
	
	var distance_squared = parent_entity.global_position.distance_squared_to(target.global_position)
	return distance_squared <= attack_range_squared

func _state_to_string(state: AIState) -> String:
	match state:
		AIState.IDLE: return "idle"
		AIState.SEEKING: return "seeking"
		AIState.ATTACKING: return "attacking"
		AIState.FLEEING: return "fleeing"
		AIState.STUNNED: return "stunned"
		_: return "unknown"

# Public interface for external systems
func set_target(new_target: Node2D):
	if target != new_target:
		target = new_target
		if target:
			target_acquired.emit(target)
		else:
			target_lost.emit()

func stun(duration: float):
	current_state = AIState.STUNNED
	# In full implementation, would set a timer

func get_current_target() -> Node2D:
	return target

func get_current_state_string() -> String:
	return _state_to_string(current_state)

func get_current_lod() -> DetailLevel:
	return current_lod

# Debug information
func get_debug_info() -> Dictionary:
	var distance_to_player = -1.0
	if player_reference:
		distance_to_player = parent_entity.global_position.distance_to(player_reference.global_position)
	
	return {
		"current_state": _state_to_string(current_state),
		"current_lod": current_lod,
		"has_target": target != null,
		"distance_to_player": distance_to_player,
		"update_group": update_group,
		"attack_cooldown": attack_cooldown,
		"sight_lost_timer": sight_lost_timer,
		"can_see_target": _can_see_target(),
		"in_attack_range": _is_in_attack_range()
	}