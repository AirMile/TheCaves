extends Node
class_name HealthComponent

signal died
signal health_changed(new_health: int, max_health: int)
signal damage_taken(amount: int)
signal healed(amount: int)

@export var max_health: int = 100
@export var start_at_full_health: bool = true
@export var invulnerability_time: float = 0.0

var current_health: int
var is_invulnerable: bool = false

@onready var invulnerability_timer: Timer

func _ready():
	if invulnerability_time > 0.0:
		invulnerability_timer = Timer.new()
		invulnerability_timer.wait_time = invulnerability_time
		invulnerability_timer.one_shot = true
		invulnerability_timer.timeout.connect(_on_invulnerability_timeout)
		add_child(invulnerability_timer)
	
	if start_at_full_health:
		current_health = max_health
	
	health_changed.emit(current_health, max_health)

func take_damage(amount: int, ignore_invulnerability: bool = false) -> bool:
	if amount <= 0:
		return false
	
	if is_invulnerable and not ignore_invulnerability:
		return false
	
	var old_health = current_health
	current_health = max(0, current_health - amount)
	
	if current_health != old_health:
		damage_taken.emit(amount)
		health_changed.emit(current_health, max_health)
		
		if current_health <= 0:
			died.emit()
		elif invulnerability_time > 0.0 and not ignore_invulnerability:
			_start_invulnerability()
	
	return true

func heal(amount: int) -> bool:
	if amount <= 0:
		return false
	
	var old_health = current_health
	current_health = min(max_health, current_health + amount)
	
	if current_health != old_health:
		healed.emit(amount)
		health_changed.emit(current_health, max_health)
		return true
	
	return false

func set_max_health(new_max_health: int, heal_to_full: bool = false):
	if new_max_health <= 0:
		return
	
	var health_ratio = float(current_health) / float(max_health) if max_health > 0 else 1.0
	max_health = new_max_health
	
	if heal_to_full:
		current_health = max_health
	else:
		current_health = int(max_health * health_ratio)
	
	health_changed.emit(current_health, max_health)

func get_health_percentage() -> float:
	if max_health <= 0:
		return 0.0
	return float(current_health) / float(max_health)

func is_at_full_health() -> bool:
	return current_health >= max_health

func is_dead() -> bool:
	return current_health <= 0

func get_current_health() -> int:
	return current_health

func get_max_health() -> int:
	return max_health

func reset_to_full_health():
	current_health = max_health
	is_invulnerable = false
	if invulnerability_timer:
		invulnerability_timer.stop()
	health_changed.emit(current_health, max_health)

func _start_invulnerability():
	if invulnerability_timer:
		is_invulnerable = true
		invulnerability_timer.start()

func _on_invulnerability_timeout():
	is_invulnerable = false

func get_invulnerability_remaining() -> float:
	if invulnerability_timer and is_invulnerable:
		return invulnerability_timer.time_left
	return 0.0