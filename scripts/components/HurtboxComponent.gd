extends Area2D
class_name HurtboxComponent
## Damage-receiving collision area for entities
## Handles incoming damage detection and forwarding

signal damage_received(damage: int, source: Node2D)
signal hit_by_attack(attacker: Node2D)

@export var is_vulnerable: bool = true
@export var damage_multiplier: float = 1.0

# Parent references
var parent_entity: Node
var health_component: HealthComponent

func _ready():
	parent_entity = get_parent()
	
	# Try to find HealthComponent on parent
	health_component = parent_entity.get_node("HealthComponent") as HealthComponent
	if not health_component:
		push_warning("HurtboxComponent: No HealthComponent found on parent")
	
	# Connect collision signals
	connect("area_entered", _on_area_entered)
	
	# Validate configuration
	damage_multiplier = maxf(0.0, damage_multiplier)

func _on_area_entered(area: Area2D):
	if area is HitboxComponent:
		_receive_damage_from_hitbox(area)

func _receive_damage_from_hitbox(hitbox: HitboxComponent) -> bool:
	if not is_vulnerable or not hitbox.is_active:
		return false
	
	# Calculate actual damage
	var base_damage = hitbox.get_damage()
	var actual_damage = int(base_damage * damage_multiplier)
	actual_damage = maxi(1, actual_damage)  # Always take at least 1 damage
	
	# Apply damage through HealthComponent
	var damage_taken = false
	if health_component:
		damage_taken = health_component.take_damage(actual_damage)
	
	if damage_taken:
		# Emit signals
		damage_received.emit(actual_damage, hitbox.parent_entity)
		hit_by_attack.emit(hitbox.parent_entity)
		
		return true
	
	return false

# Status management
func set_vulnerability(vulnerable: bool):
	is_vulnerable = vulnerable
	monitorable = vulnerable

func set_damage_multiplier(multiplier: float):
	damage_multiplier = maxf(0.0, multiplier)

# Temporary invulnerability (often used with HealthComponent)
func make_temporarily_invulnerable(duration: float):
	is_vulnerable = false
	
	# Create timer for restoration
	var timer = get_tree().create_timer(duration)
	timer.timeout.connect(_restore_vulnerability)

func _restore_vulnerability():
	is_vulnerable = true

# Integration with upgrade system
func apply_damage_reduction(reduction: float):
	# Reduces incoming damage by percentage
	var new_multiplier = damage_multiplier * (1.0 - clampf(reduction, 0.0, 0.9))
	set_damage_multiplier(new_multiplier)

func apply_damage_increase(increase: float):
	# Increases incoming damage by percentage (for difficulty scaling)
	var new_multiplier = damage_multiplier * (1.0 + maxf(0.0, increase))
	set_damage_multiplier(new_multiplier)

# Reset for object pooling
func reset_for_pool():
	is_vulnerable = true
	damage_multiplier = 1.0
	monitorable = true

# Getters
func get_damage_multiplier() -> float:
	return damage_multiplier

func is_taking_damage() -> bool:
	return is_vulnerable and monitorable

# Debug information
func get_debug_info() -> Dictionary:
	return {
		"is_vulnerable": is_vulnerable,
		"damage_multiplier": damage_multiplier,
		"monitorable": monitorable,
		"has_health_component": health_component != null
	}