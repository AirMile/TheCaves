extends Area2D
class_name HitboxComponent

signal hit(hurtbox: HurtboxComponent)

@export var damage: int = 10
@export var knockback_force: float = 0.0
@export var enabled: bool = true

var collision_exceptions: Array[HurtboxComponent] = []

func _ready():
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _on_area_entered(area: Area2D):
	if not enabled:
		return
	
	var hurtbox = area as HurtboxComponent
	if hurtbox and hurtbox.can_be_hit_by(self) and not collision_exceptions.has(hurtbox):
		_process_hit(hurtbox)

func _on_body_entered(body: Node2D):
	if not enabled:
		return
	
	var hurtbox = body.get_node("HurtboxComponent") as HurtboxComponent
	if hurtbox and hurtbox.can_be_hit_by(self) and not collision_exceptions.has(hurtbox):
		_process_hit(hurtbox)

func _process_hit(hurtbox: HurtboxComponent):
	var actual_damage = damage
	var actual_knockback = knockback_force
	
	if hurtbox.take_hit(actual_damage, actual_knockback, self):
		hit.emit(hurtbox)
		_handle_hit_effects(hurtbox)

func _handle_hit_effects(hurtbox: HurtboxComponent):
	if knockback_force > 0.0:
		var knockback_direction = (hurtbox.global_position - global_position).normalized()
		if knockback_direction.length() < 0.1:
			knockback_direction = Vector2.RIGHT
		
		if hurtbox.has_method("apply_knockback"):
			hurtbox.apply_knockback(knockback_direction * knockback_force)

func set_damage(new_damage: int):
	damage = max(0, new_damage)

func get_damage() -> int:
	return damage

func set_enabled(is_enabled: bool):
	enabled = is_enabled
	set_monitoring(enabled)
	set_monitorable(enabled)

func is_enabled() -> bool:
	return enabled

func add_collision_exception(hurtbox: HurtboxComponent):
	if not collision_exceptions.has(hurtbox):
		collision_exceptions.append(hurtbox)

func remove_collision_exception(hurtbox: HurtboxComponent):
	collision_exceptions.erase(hurtbox)

func clear_collision_exceptions():
	collision_exceptions.clear()

func get_collision_exceptions() -> Array[HurtboxComponent]:
	return collision_exceptions.duplicate()