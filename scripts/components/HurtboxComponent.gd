extends Area2D
class_name HurtboxComponent

signal hit_taken(damage: int, knockback: float, hitbox: HitboxComponent)

@export var hit_layer_mask: int = 0  # Which layers can hit this hurtbox
@export var invulnerability_time: float = 0.0
@export var enabled: bool = true

var is_invulnerable: bool = false
var invulnerability_timer: Timer

@onready var health_component: HealthComponent
@onready var movement_component: MovementComponent

func _ready():
	health_component = get_parent().get_node("HealthComponent") as HealthComponent
	movement_component = get_parent().get_node("MovementComponent") as MovementComponent
	
	if invulnerability_time > 0.0:
		invulnerability_timer = Timer.new()
		invulnerability_timer.wait_time = invulnerability_time
		invulnerability_timer.one_shot = true
		invulnerability_timer.timeout.connect(_on_invulnerability_timeout)
		add_child(invulnerability_timer)

func can_be_hit_by(hitbox: HitboxComponent) -> bool:
	if not enabled or is_invulnerable:
		return false
	
	if hit_layer_mask > 0:
		var hitbox_layer = hitbox.collision_layer
		return (hit_layer_mask & hitbox_layer) != 0
	
	return true

func take_hit(damage: int, knockback_force: float, hitbox: HitboxComponent) -> bool:
	if not can_be_hit_by(hitbox):
		return false
	
	if health_component:
		health_component.take_damage(damage)
	
	if knockback_force > 0.0:
		apply_knockback_from_hitbox(hitbox, knockback_force)
	
	if invulnerability_time > 0.0:
		_start_invulnerability()
	
	hit_taken.emit(damage, knockback_force, hitbox)
	
	return true

func apply_knockback_from_hitbox(hitbox: HitboxComponent, force: float):
	var knockback_direction = (global_position - hitbox.global_position).normalized()
	if knockback_direction.length() < 0.1:
		knockback_direction = Vector2.RIGHT
	
	apply_knockback(knockback_direction * force)

func apply_knockback(knockback_vector: Vector2):
	if movement_component:
		movement_component.apply_impulse(knockback_vector)
	elif get_parent() is CharacterBody2D:
		var body = get_parent() as CharacterBody2D
		body.velocity += knockback_vector

func _start_invulnerability():
	if invulnerability_timer:
		is_invulnerable = true
		invulnerability_timer.start()

func _on_invulnerability_timeout():
	is_invulnerable = false

func set_enabled(is_enabled: bool):
	enabled = is_enabled
	set_monitoring(enabled)
	set_monitorable(enabled)

func is_enabled() -> bool:
	return enabled

func get_invulnerability_remaining() -> float:
	if invulnerability_timer and is_invulnerable:
		return invulnerability_timer.time_left
	return 0.0

func set_hit_layer_mask(mask: int):
	hit_layer_mask = mask