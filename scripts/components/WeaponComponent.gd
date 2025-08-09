extends Node
class_name WeaponComponent

enum WeaponType { MELEE, PROJECTILE, MAGIC, ORBITAL }

signal weapon_fired(projectile: Node2D)
signal weapon_hit(target: Node2D, damage: int)
signal weapon_reloaded

@export var weapon_type: WeaponType = WeaponType.PROJECTILE
@export var weapon_name: String = "Basic Weapon"
@export var base_damage: int = 10
@export var fire_rate: float = 1.0
@export var range: float = 300.0
@export var projectile_speed: float = 400.0
@export var projectile_count: int = 1
@export var spread_angle: float = 0.0
@export var auto_fire: bool = true
@export var pierce_count: int = 0

var current_damage: int
var current_fire_rate: float
var current_range: float
var can_fire: bool = true
var targets_in_range: Array[Node2D] = []
var fire_timer: Timer

@onready var parent_entity: Node2D
@onready var stats_component: StatsComponent
@onready var detection_area: Area2D

func _ready():
	parent_entity = get_parent()
	stats_component = parent_entity.get_node("StatsComponent") as StatsComponent
	
	_initialize_weapon()
	_setup_detection_area()
	_setup_fire_timer()
	
	if stats_component:
		stats_component.stat_changed.connect(_on_stat_changed)

func _initialize_weapon():
	current_damage = base_damage
	current_fire_rate = fire_rate
	current_range = range
	
	if stats_component:
		current_damage = int(stats_component.get_stat("damage"))
		current_fire_rate = stats_component.get_stat("fire_rate")

func _setup_detection_area():
	detection_area = Area2D.new()
	detection_area.name = "WeaponDetectionArea"
	add_child(detection_area)
	
	var collision_shape = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = current_range
	collision_shape.shape = circle_shape
	detection_area.add_child(collision_shape)
	
	detection_area.body_entered.connect(_on_target_entered)
	detection_area.body_exited.connect(_on_target_exited)
	detection_area.area_entered.connect(_on_area_target_entered)
	detection_area.area_exited.connect(_on_area_target_exited)

func _setup_fire_timer():
	fire_timer = Timer.new()
	fire_timer.name = "FireTimer"
	fire_timer.wait_time = 1.0 / current_fire_rate
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	add_child(fire_timer)
	fire_timer.start()

func _process(delta):
	if auto_fire and can_fire and targets_in_range.size() > 0:
		_attempt_fire()

func _attempt_fire():
	if not can_fire:
		return
	
	var target = _get_closest_target()
	if not target:
		return
	
	_fire_at_target(target)

func _fire_at_target(target: Node2D):
	match weapon_type:
		WeaponType.PROJECTILE:
			_fire_projectile(target)
		WeaponType.MELEE:
			_fire_melee(target)
		WeaponType.MAGIC:
			_fire_magic(target)
		WeaponType.ORBITAL:
			_fire_orbital(target)

func _fire_projectile(target: Node2D):
	var base_direction = (target.global_position - parent_entity.global_position).normalized()
	
	for i in projectile_count:
		var angle_offset = 0.0
		if projectile_count > 1:
			angle_offset = spread_angle * (i - (projectile_count - 1) * 0.5) / (projectile_count - 1)
		
		var direction = base_direction.rotated(deg_to_rad(angle_offset))
		var projectile = ProjectileManager.fire_projectile(
			"bullet",
			parent_entity.global_position,
			direction,
			projectile_speed,
			current_damage,
			parent_entity.is_in_group("player")
		)
		
		if projectile:
			weapon_fired.emit(projectile)
	
	EventBus.weapon_fired.emit(weapon_name, parent_entity.global_position, base_direction)
	_start_cooldown()

func _fire_melee(target: Node2D):
	var distance = parent_entity.global_position.distance_to(target.global_position)
	if distance <= current_range:
		if target.has_method("take_damage"):
			target.take_damage(current_damage)
		elif target.has_node("HealthComponent"):
			var health_comp = target.get_node("HealthComponent") as HealthComponent
			health_comp.take_damage(current_damage)
		
		weapon_hit.emit(target, current_damage)
	
	_start_cooldown()

func _fire_magic(target: Node2D):
	var projectile = ProjectileManager.fire_projectile(
		"magic_bolt",
		parent_entity.global_position,
		(target.global_position - parent_entity.global_position).normalized(),
		projectile_speed * 1.2,
		int(current_damage * 1.3),
		parent_entity.is_in_group("player")
	)
	
	if projectile:
		weapon_fired.emit(projectile)
	
	_start_cooldown()

func _fire_orbital(target: Node2D):
	pass

func _start_cooldown():
	can_fire = false
	fire_timer.wait_time = 1.0 / current_fire_rate
	fire_timer.start()

func _on_fire_timer_timeout():
	can_fire = true

func _get_closest_target() -> Node2D:
	if targets_in_range.is_empty():
		return null
	
	var closest_target: Node2D = null
	var closest_distance: float = INF
	
	for target in targets_in_range:
		if not is_instance_valid(target):
			continue
		
		var distance = parent_entity.global_position.distance_squared_to(target.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_target = target
	
	return closest_target

func _on_target_entered(body: Node2D):
	if _is_valid_target(body):
		targets_in_range.append(body)

func _on_target_exited(body: Node2D):
	targets_in_range.erase(body)

func _on_area_target_entered(area: Area2D):
	var body = area.get_parent()
	if _is_valid_target(body):
		targets_in_range.append(body)

func _on_area_target_exited(area: Area2D):
	var body = area.get_parent()
	targets_in_range.erase(body)

func _is_valid_target(target: Node2D) -> bool:
	if not target or not is_instance_valid(target):
		return false
	
	if parent_entity.is_in_group("player"):
		return target.is_in_group("enemies")
	elif parent_entity.is_in_group("enemies"):
		return target.is_in_group("player")
	
	return false

func _on_stat_changed(stat_name: String, old_value: float, new_value: float):
	match stat_name:
		"damage":
			current_damage = int(new_value)
		"fire_rate":
			current_fire_rate = new_value
		"range":
			current_range = new_value
			_update_detection_range()

func _update_detection_range():
	if detection_area:
		var collision_shape = detection_area.get_child(0) as CollisionShape2D
		if collision_shape and collision_shape.shape is CircleShape2D:
			var circle_shape = collision_shape.shape as CircleShape2D
			circle_shape.radius = current_range

func set_weapon_stats(damage: int, fire_rate_val: float, range_val: float = -1.0):
	current_damage = damage
	current_fire_rate = fire_rate_val
	
	if range_val > 0:
		current_range = range_val
		_update_detection_range()
	
	if fire_timer:
		fire_timer.wait_time = 1.0 / current_fire_rate

func get_weapon_stats() -> Dictionary:
	return {
		"weapon_name": weapon_name,
		"weapon_type": WeaponType.keys()[weapon_type],
		"damage": current_damage,
		"fire_rate": current_fire_rate,
		"range": current_range,
		"projectile_count": projectile_count,
		"targets_in_range": targets_in_range.size(),
		"can_fire": can_fire
	}