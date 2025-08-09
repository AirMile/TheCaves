extends Node
class_name HealthComponent
## Handles health, damage, healing, and invulnerability mechanics
## Designed for flexible health management across all entities

signal health_changed(current_health: int, max_health: int)
signal health_depleted
signal damage_taken(amount: int)
signal healed(amount: int)

@export var max_health: int = 100
@export var invulnerability_duration: float = 0.5
@export var damage_reduction: float = 0.0  # 0.0 to 1.0 (0% to 100% reduction)

var current_health: int
var is_invulnerable: bool = false
var invulnerability_timer: float = 0.0

# Parent entity reference for cleanup and events
var parent_entity: Node

func _ready():
	parent_entity = get_parent()
	current_health = max_health
	
	# Validate configuration
	if max_health <= 0:
		push_error("HealthComponent: max_health must be positive, got: %d" % max_health)
		max_health = 1
		current_health = max_health
	
	damage_reduction = clampf(damage_reduction, 0.0, 1.0)

func _process(delta: float):
	if is_invulnerable:
		invulnerability_timer -= delta
		if invulnerability_timer <= 0.0:
			is_invulnerable = false
			_on_invulnerability_ended()

func take_damage(amount: int, ignore_invulnerability: bool = false) -> bool:
	# Validate input - prevent negative damage or overflow
	if amount <= 0:
		return false
	
	# Check invulnerability
	if is_invulnerable and not ignore_invulnerability:
		return false
	
	# Apply damage reduction
	var actual_damage = int(amount * (1.0 - damage_reduction))
	actual_damage = maxi(1, actual_damage)  # Always deal at least 1 damage
	
	# Ensure we don't underflow
	var previous_health = current_health
	current_health = maxi(0, current_health - actual_damage)
	
	# Emit signals
	damage_taken.emit(actual_damage)
	health_changed.emit(current_health, max_health)
	
	# Start invulnerability if we took damage and aren't already invulnerable
	if current_health < previous_health and invulnerability_duration > 0.0:
		_start_invulnerability()
	
	# Check for death
	if current_health <= 0 and previous_health > 0:
		health_depleted.emit()
		_on_health_depleted()
	
	# Play damage audio if AudioManager available
	if AudioManager and parent_entity:
		AudioManager.play_enemy_hit(parent_entity.global_position)
	
	return true

func heal(amount: int) -> bool:
	if amount <= 0:
		return false
	
	# Prevent overflow  
	var previous_health = current_health
	current_health = mini(max_health, current_health + amount)
	
	if current_health > previous_health:
		var actual_healing = current_health - previous_health
		healed.emit(actual_healing)
		health_changed.emit(current_health, max_health)
		return true
	
	return false

func set_max_health(new_max: int, heal_to_max: bool = false):
	if new_max <= 0:
		push_error("HealthComponent: Invalid max_health: %d" % new_max)
		return
	
	var _old_max = max_health
	max_health = new_max
	
	if heal_to_max:
		current_health = max_health
	else:
		# Maintain current health percentage if possible
		current_health = mini(current_health, max_health)
	
	health_changed.emit(current_health, max_health)

func _start_invulnerability():
	is_invulnerable = true
	invulnerability_timer = invulnerability_duration
	_on_invulnerability_started()

func _on_invulnerability_started():
	# Override in derived components for visual effects
	pass

func _on_invulnerability_ended():
	# Override in derived components for visual effects
	pass

func _on_health_depleted():
	# Handle death logic
	if AudioManager and parent_entity:
		AudioManager.play_enemy_death(parent_entity.global_position)

# Getters with validation
func get_health() -> int:
	return current_health

func get_max_health() -> int:
	return max_health

func get_health_percentage() -> float:
	if max_health <= 0:
		return 0.0
	return float(current_health) / float(max_health)

func is_at_max_health() -> bool:
	return current_health >= max_health

func is_dead() -> bool:
	return current_health <= 0

func get_invulnerability_remaining() -> float:
	if not is_invulnerable:
		return 0.0
	return max(0.0, invulnerability_timer)

# Utility functions for upgrades
func modify_damage_reduction(modifier: float):
	damage_reduction = clampf(damage_reduction + modifier, 0.0, 0.9)  # Cap at 90% reduction

func reset_to_full():
	current_health = max_health
	is_invulnerable = false
	invulnerability_timer = 0.0
	health_changed.emit(current_health, max_health)

# Debug information
func get_debug_info() -> Dictionary:
	return {
		"current_health": current_health,
		"max_health": max_health,
		"health_percentage": get_health_percentage(),
		"is_invulnerable": is_invulnerable,
		"invulnerability_remaining": get_invulnerability_remaining(),
		"damage_reduction": damage_reduction
	}