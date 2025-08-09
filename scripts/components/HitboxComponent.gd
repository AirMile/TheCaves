extends Area2D
class_name HitboxComponent
## Damage-dealing collision area for weapons and attacks
## Handles damage output and collision detection

signal hit_target(target: Node2D, damage: int)

@export var damage: int = 10
@export var knockback_force: float = 100.0
@export var hit_cooldown: float = 0.1  # Prevent multiple hits per frame
@export var pierce_count: int = 1  # How many targets can be hit before deactivating

var targets_hit: Array[Node2D] = []
var is_active: bool = true
var hit_cooldown_timer: float = 0.0

# Parent reference for cleanup
var parent_entity: Node

func _ready():
	parent_entity = get_parent()
	
	# Connect collision signals
	connect("area_entered", _on_area_entered)
	connect("body_entered", _on_body_entered)
	
	# Validate configuration
	if damage <= 0:
		push_warning("HitboxComponent: damage should be positive, got: %d" % damage)
		damage = 1

func _process(delta: float):
	if hit_cooldown_timer > 0.0:
		hit_cooldown_timer -= delta

func _on_area_entered(area: Area2D):
	if area is HurtboxComponent:
		_attempt_hit(area.get_parent())

func _on_body_entered(body: Node2D):
	# Direct body collision for enemies/players without hurtbox components
	_attempt_hit(body)

func _attempt_hit(target: Node2D) -> bool:
	if not _can_hit_target(target):
		return false
	
	# Apply damage through HealthComponent if available
	var health_component = target.get_node("HealthComponent") as HealthComponent
	if health_component:
		var damage_dealt = health_component.take_damage(damage)
		if damage_dealt:
			_on_successful_hit(target)
			return true
	else:
		# Fallback for targets without HealthComponent
		_on_successful_hit(target)
		return true
	
	return false

func _can_hit_target(target: Node2D) -> bool:
	# Basic validation
	if not is_instance_valid(target) or not is_active:
		return false
	
	# Cooldown check
	if hit_cooldown_timer > 0.0:
		return false
	
	# Don't hit the same target twice unless pierce allows it
	if target in targets_hit:
		return false
	
	# Don't hit parent entity (self-damage prevention)
	if target == parent_entity or target == get_parent():
		return false
	
	return true

func _on_successful_hit(target: Node2D):
	# Track hit target
	targets_hit.append(target)
	
	# Apply knockback if target has MovementComponent
	var movement_component = target.get_node("MovementComponent") as MovementComponent
	if movement_component and knockback_force > 0.0:
		var knockback_direction = (target.global_position - global_position).normalized()
		# Note: Full knockback implementation would require additional methods
	
	# Emit hit signal
	hit_target.emit(target, damage)
	
	# Start hit cooldown
	hit_cooldown_timer = hit_cooldown
	
	# Check pierce limit
	if targets_hit.size() >= pierce_count:
		deactivate()
	
	# Play hit audio
	if AudioManager:
		AudioManager.play_enemy_hit(target.global_position)

func activate():
	is_active = true
	targets_hit.clear()
	hit_cooldown_timer = 0.0
	monitoring = true
	monitorable = true

func deactivate():
	is_active = false
	monitoring = false
	monitorable = false

# Upgrade system support
func modify_damage(multiplier: float):
	damage = maxi(1, int(damage * multiplier))

func add_damage_bonus(bonus: int):
	damage = maxi(1, damage + bonus)

func set_pierce_count(new_pierce: int):
	pierce_count = maxi(1, new_pierce)

func modify_knockback(multiplier: float):
	knockback_force = maxf(0.0, knockback_force * multiplier)

# Reset for object pooling
func reset_for_pool():
	targets_hit.clear()
	is_active = true
	hit_cooldown_timer = 0.0
	monitoring = true
	monitorable = true

# Getters
func get_damage() -> int:
	return damage

func get_targets_hit_count() -> int:
	return targets_hit.size()

func can_still_hit() -> bool:
	return is_active and targets_hit.size() < pierce_count

func get_remaining_pierce() -> int:
	return max(0, pierce_count - targets_hit.size())

# Debug information
func get_debug_info() -> Dictionary:
	return {
		"damage": damage,
		"knockback_force": knockback_force,
		"pierce_count": pierce_count,
		"targets_hit": targets_hit.size(),
		"is_active": is_active,
		"can_still_hit": can_still_hit(),
		"hit_cooldown_remaining": max(0.0, hit_cooldown_timer)
	}