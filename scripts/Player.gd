extends CharacterBody2D
class_name Player

signal experience_gained(amount: int)
signal level_up(new_level: int)

@export var dash_distance: float = 200.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 1.5

var player_level: int = 1
var current_experience: int = 0
var experience_to_next_level: int = 100

var is_dashing: bool = false
var can_dash: bool = true
var dash_direction: Vector2 = Vector2.ZERO

@onready var health_component: HealthComponent = $HealthComponent
@onready var movement_component: MovementComponent = $MovementComponent
@onready var stats_component: StatsComponent = $StatsComponent
@onready var weapon_component: WeaponComponent = $WeaponComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent

@onready var dash_timer: Timer = Timer.new()
@onready var dash_cooldown_timer: Timer = Timer.new()

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready():
	add_to_group("player")
	
	_setup_timers()
	_setup_components()
	_connect_signals()
	
	if OS.is_debug_build():
		print("[Player] Initialized - Level %d, Health: %d/%d" % [player_level, health_component.current_health, health_component.max_health])

func _setup_timers():
	dash_timer.wait_time = dash_duration
	dash_timer.one_shot = true
	dash_timer.timeout.connect(_on_dash_timer_timeout)
	add_child(dash_timer)
	
	dash_cooldown_timer.wait_time = dash_cooldown
	dash_cooldown_timer.one_shot = true
	dash_cooldown_timer.timeout.connect(_on_dash_cooldown_timeout)
	add_child(dash_cooldown_timer)

func _setup_components():
	if health_component:
		health_component.max_health = int(stats_component.get_stat("max_health"))
		health_component.reset_to_full_health()
	
	if movement_component:
		movement_component.max_speed = stats_component.get_stat("speed")
	
	if hurtbox_component:
		hurtbox_component.hit_layer_mask = 8 | 32  # Enemy projectiles + Enemies
	
	collision_layer = 2  # Player layer
	collision_mask = 1   # Walls only (no enemy collision for performance)

func _connect_signals():
	if health_component:
		health_component.died.connect(_on_player_died)
		health_component.health_changed.connect(_on_health_changed)
	
	EventBus.pickup_collected.connect(_on_pickup_collected)
	stats_component.stat_changed.connect(_on_stat_changed)

func _physics_process(delta):
	if not GameManager.is_game_active():
		return
	
	_handle_input()
	_update_dash_movement(delta)

func _handle_input():
	if is_dashing:
		return
	
	var input_direction = InputManager.get_movement_vector()
	movement_component.set_input_direction(input_direction)
	
	if InputManager.is_dash_just_pressed() and can_dash and input_direction.length() > 0.1:
		_start_dash(input_direction)

func _start_dash(direction: Vector2):
	is_dashing = true
	can_dash = false
	dash_direction = direction.normalized()
	
	movement_component.stop_immediately()
	
	dash_timer.start()
	dash_cooldown_timer.start()
	
	EventBus.player_stats_changed.emit()
	AudioManager.play_sfx("player_dash", -10.0, randf_range(0.9, 1.1))

func _update_dash_movement(delta: float):
	if is_dashing:
		var dash_velocity = dash_direction * (dash_distance / dash_duration)
		velocity = dash_velocity
		move_and_slide()

func _on_dash_timer_timeout():
	is_dashing = false

func _on_dash_cooldown_timeout():
	can_dash = true

func _on_player_died():
	EventBus.player_died.emit()
	AudioManager.play_sfx("player_hurt")

func _on_health_changed(new_health: int, max_health: int):
	EventBus.player_health_changed.emit(new_health, max_health)

func _on_pickup_collected(pickup_type: String, value: int, position: Vector2):
	match pickup_type:
		"experience":
			gain_experience(value)
		"health":
			if health_component:
				health_component.heal(value)

func _on_stat_changed(stat_name: String, old_value: float, new_value: float):
	match stat_name:
		"max_health":
			if health_component:
				health_component.set_max_health(int(new_value))
		"speed":
			if movement_component:
				movement_component.set_max_speed(new_value)

func gain_experience(amount: int):
	var actual_amount = int(amount * stats_component.get_stat("experience_multiplier"))
	current_experience += actual_amount
	
	experience_gained.emit(actual_amount)
	EventBus.player_gained_experience.emit(actual_amount)
	
	var exp_needed = _get_experience_for_level(player_level + 1)
	if current_experience >= exp_needed:
		_level_up()

func _level_up():
	player_level += 1
	current_experience = 0
	
	level_up.emit(player_level)
	EventBus.player_leveled_up.emit(player_level)
	
	AudioManager.play_sfx("level_up", 0.0, 1.0)

func _get_experience_for_level(level: int) -> int:
	return int(100 * pow(1.2, level - 1))

func get_experience_to_next_level() -> int:
	return _get_experience_for_level(player_level + 1) - current_experience

func get_experience_progress() -> float:
	var exp_needed = _get_experience_for_level(player_level + 1)
	if exp_needed <= 0:
		return 1.0
	return float(current_experience) / float(exp_needed)

func apply_upgrade(upgrade_id: String):
	match upgrade_id:
		"damage_boost":
			stats_component.add_stat_modifier("damage", "upgrade_damage", 5.0, false)
		"fire_rate_boost":
			stats_component.add_stat_modifier("fire_rate", "upgrade_fire_rate", 0.2, true)
		"speed_boost":
			stats_component.add_stat_modifier("speed", "upgrade_speed", 0.15, true)
		"health_boost":
			stats_component.add_stat_modifier("max_health", "upgrade_health", 25.0, false)
		"experience_boost":
			stats_component.add_stat_modifier("experience_multiplier", "upgrade_exp", 0.2, true)
		"dash_cooldown":
			dash_cooldown = max(0.5, dash_cooldown - 0.2)
			dash_cooldown_timer.wait_time = dash_cooldown
		"pickup_range":
			stats_component.add_stat_modifier("pickup_range", "upgrade_pickup", 0.3, true)
	
	EventBus.player_stats_changed.emit()

func get_player_stats() -> Dictionary:
	return {
		"level": player_level,
		"health": health_component.current_health if health_component else 0,
		"max_health": health_component.max_health if health_component else 0,
		"experience": current_experience,
		"experience_to_next": get_experience_to_next_level(),
		"experience_progress": get_experience_progress(),
		"can_dash": can_dash,
		"is_dashing": is_dashing,
		"dash_cooldown_remaining": dash_cooldown_timer.time_left if dash_cooldown_timer else 0.0,
		"position": global_position
	}

func reset_player():
	player_level = 1
	current_experience = 0
	is_dashing = false
	can_dash = true
	
	if health_component:
		health_component.reset_to_full_health()
	
	stats_component.clear_all_modifiers()
	
	dash_cooldown_timer.stop()
	dash_timer.stop()