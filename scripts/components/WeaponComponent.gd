extends Node
class_name WeaponComponent
## Auto-attacking weapon system with multiple weapon types
## Handles targeting, firing, and projectile management with proper cleanup

signal weapon_fired(projectile: Node2D)
signal target_acquired(target: Node2D)
signal target_lost

enum WeaponType { MELEE, PROJECTILE, MAGIC, ORBITAL }

@export var weapon_type: WeaponType = WeaponType.PROJECTILE
@export var damage: int = 10
@export var fire_rate: float = 2.0  # Attacks per second
@export var range: float = 150.0
@export var auto_target: bool = true
@export var projectile_speed: float = 300.0
@export var projectile_type: String = "bullet"

# State management
var current_target: Node2D = null
var fire_cooldown: float = 0.0
var targets_in_range: Array[Node2D] = []

# Cached references for performance
var parent_entity: Node2D
var stats_component: StatsComponent
var range_squared: float  # Pre-calculated for performance

# Target validation
var target_cleanup_timer: float = 0.0
const TARGET_CLEANUP_INTERVAL: float = 0.5

func _ready():
	parent_entity = get_parent()
	stats_component = parent_entity.get_node("StatsComponent") as StatsComponent
	
	# Pre-calculate range squared for performance
	range_squared = range * range
	
	# Validate configuration
	if fire_rate <= 0:
		push_error("WeaponComponent: fire_rate must be positive")
		fire_rate = 1.0
	
	if damage <= 0:
		push_warning("WeaponComponent: damage should be positive")
		damage = 1

func _process(delta: float):
	_update_fire_cooldown(delta)
	_update_target_cleanup(delta)
	
	if auto_target:
		_update_auto_targeting()
	
	if _can_fire():
		_attempt_fire()

func _update_fire_cooldown(delta: float):
	if fire_cooldown > 0.0:
		var effective_fire_rate = fire_rate
		
		# Apply attack speed modifier from stats if available
		if stats_component:
			effective_fire_rate *= stats_component.get_attack_speed()
		
		fire_cooldown -= delta * effective_fire_rate

func _update_target_cleanup(delta: float):
	target_cleanup_timer += delta
	
	if target_cleanup_timer >= TARGET_CLEANUP_INTERVAL:
		_cleanup_invalid_targets()
		target_cleanup_timer = 0.0

func _cleanup_invalid_targets():
	# Clean up invalid targets from the array (addressing feedback issue)
	for i in range(targets_in_range.size() - 1, -1, -1):
		var target = targets_in_range[i]
		if not is_instance_valid(target) or _is_target_dead(target):
			targets_in_range.remove_at(i)
			if target == current_target:
				current_target = null
				target_lost.emit()

func _is_target_dead(target: Node2D) -> bool:
	if not is_instance_valid(target):
		return true
	
	var health_component = target.get_node("HealthComponent") as HealthComponent
	if health_component and health_component.is_dead():
		return true
	
	return false

func _update_auto_targeting():
	if current_target and _is_valid_target(current_target):
		return  # Keep current target if still valid
	
	# Find new target
	_find_new_target()

func _find_new_target():
	var best_target: Node2D = null
	var closest_distance_squared: float = range_squared + 1.0
	
	# Update targets in range
	_scan_for_targets()
	
	# Find closest valid target using distance_squared_to for performance
	for target in targets_in_range:
		if not _is_valid_target(target):
			continue
		
		var distance_squared = parent_entity.global_position.distance_squared_to(target.global_position)
		if distance_squared < closest_distance_squared:
			best_target = target
			closest_distance_squared = distance_squared
	
	# Update current target
	if best_target != current_target:
		if current_target:
			target_lost.emit()
		
		current_target = best_target
		
		if current_target:
			target_acquired.emit(current_target)

func _scan_for_targets():
	# Find enemies in range - in production would use Area2D or collision detection
	var enemies = get_tree().get_nodes_in_group("enemies")
	targets_in_range.clear()
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
			
		var distance_squared = parent_entity.global_position.distance_squared_to(enemy.global_position)
		if distance_squared <= range_squared:
			targets_in_range.append(enemy)

func _is_valid_target(target: Node2D) -> bool:
	if not is_instance_valid(target):
		return false
	
	if _is_target_dead(target):
		return false
	
	# Check if target is still in range using distance_squared_to
	var distance_squared = parent_entity.global_position.distance_squared_to(target.global_position)
	return distance_squared <= range_squared

func _can_fire() -> bool:
	return fire_cooldown <= 0.0 and current_target != null and _is_valid_target(current_target)

func _attempt_fire():
	if not _can_fire():
		return
	
	match weapon_type:
		WeaponType.PROJECTILE:
			_fire_projectile()
		WeaponType.MELEE:
			_fire_melee()
		WeaponType.MAGIC:
			_fire_magic()
		WeaponType.ORBITAL:
			_fire_orbital()
	
	# Reset fire cooldown
	fire_cooldown = 1.0  # Will be modified by fire_rate in _update_fire_cooldown

func _fire_projectile():
	if not ProjectileManager or not current_target:
		return
	
	var projectile = ProjectileManager.get_projectile(projectile_type)
	if not projectile:
		push_warning("WeaponComponent: Failed to get projectile of type: %s" % projectile_type)
		return
	
	# Set projectile properties
	projectile.global_position = parent_entity.global_position
	
	# Calculate direction to target
	var direction = (current_target.global_position - parent_entity.global_position).normalized()
	
	# Set velocity (assuming RigidBody2D projectile)
	if projectile is RigidBody2D:
		projectile.linear_velocity = direction * projectile_speed
	
	# Set damage from stats
	var effective_damage = damage
	if stats_component:
		effective_damage = stats_component.get_damage()
	
	projectile.set_meta("damage", effective_damage)
	projectile.set_meta("source", parent_entity)
	
	# Emit signal and play audio
	weapon_fired.emit(projectile)
	
	if AudioManager:
		AudioManager.play_weapon_fire(parent_entity.global_position)

func _fire_melee():
	# Placeholder for melee attack - would create hitbox
	if AudioManager:
		AudioManager.play_weapon_fire(parent_entity.global_position)

func _fire_magic():
	# Placeholder for magic attack - would have special effects
	_fire_projectile()  # For now, use projectile behavior

func _fire_orbital():
	# Placeholder for orbital weapon - would create orbiting projectiles
	pass

# Manual targeting interface
func set_target(target: Node2D):
	if target != current_target:
		if current_target:
			target_lost.emit()
		
		current_target = target
		
		if current_target and _is_valid_target(current_target):
			target_acquired.emit(current_target)
		elif current_target:
			# Target is invalid
			current_target = null

func clear_target():
	if current_target:
		target_lost.emit()
		current_target = null

# Upgrade system integration
func modify_damage(multiplier: float):
	damage = maxi(1, int(damage * multiplier))

func modify_fire_rate(multiplier: float):
	fire_rate = maxf(0.1, fire_rate * multiplier)

func modify_range(multiplier: float):
	range = maxf(10.0, range * multiplier)
	range_squared = range * range

func set_weapon_type(new_type: WeaponType):
	weapon_type = new_type

# Getters with validation
func get_effective_damage() -> int:
	var effective_damage = damage
	if stats_component:
		effective_damage = stats_component.get_damage()
	return effective_damage

func get_effective_fire_rate() -> float:
	var effective_rate = fire_rate
	if stats_component:
		effective_rate *= stats_component.get_attack_speed()
	return effective_rate

func get_current_target() -> Node2D:
	return current_target if _is_valid_target(current_target) else null

func get_targets_in_range_count() -> int:
	return targets_in_range.size()

func get_fire_cooldown_remaining() -> float:
	return max(0.0, fire_cooldown)

func is_ready_to_fire() -> bool:
	return _can_fire()

# Debug information
func get_debug_info() -> Dictionary:
	return {
		"weapon_type": weapon_type,
		"damage": get_effective_damage(),
		"fire_rate": get_effective_fire_rate(),
		"range": range,
		"has_target": current_target != null,
		"targets_in_range": targets_in_range.size(),
		"fire_cooldown": get_fire_cooldown_remaining(),
		"can_fire": _can_fire(),
		"auto_target": auto_target,
		"projectile_type": projectile_type
	}