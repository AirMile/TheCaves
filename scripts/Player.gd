extends CharacterBody2D
class_name Player
## Main player controller with component-based architecture
## Handles movement, health, experience, and upgrade application

signal level_up
signal experience_gained(amount: int)
signal health_changed(current: int, maximum: int)
signal died

# Level and experience system with overflow protection
@export var starting_level: int = 1
var current_level: int
var current_experience: int = 0
var experience_to_next_level: int = 100

# Experience calculation limits to prevent overflow (as mentioned in feedback)
const MAX_EXPERIENCE: int = 1932735282  # 90% of int32 max (2147483647) for safety margin
const MAX_LEVEL: int = 100

# Component references (cached for performance)
@onready var health_component: HealthComponent = $HealthComponent
@onready var movement_component: MovementComponent = $MovementComponent
@onready var stats_component: StatsComponent = $StatsComponent
@onready var weapon_component: WeaponComponent = $WeaponComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var camera: Camera2D = $Camera2D

# Input validation constants
const MAX_INPUT_MAGNITUDE_SQUARED: float = 2.0  # Prevent excessively large input (sqrt(2)^2)
const INPUT_SPAM_LIMIT: int = 10

# Input validation state
var last_input_frame: int = 0
var input_spam_count: int = 0

func _ready():
	# Initialize player
	current_level = starting_level
	add_to_group("player")
	
	# Validate component setup
	_validate_components()
	
	# Connect component signals
	_connect_component_signals()
	
	# Set collision layers for player
	collision_layer = 2  # Player layer
	collision_mask = 1 | 3  # Walls and enemies
	
	# Configure hitbox/hurtbox integration
	_setup_collision_components()
	
	# Apply initial stats
	_apply_stats_to_components()
	
	# Setup camera
	_setup_camera()
	
	print(EnemyPool.PLAYER_INIT_FORMAT % [current_level, health_component.get_max_health()])

func _validate_components():
	var missing_components = []
	
	if not health_component:
		missing_components.append("HealthComponent")
	if not movement_component:
		missing_components.append("MovementComponent")
	if not stats_component:
		missing_components.append("StatsComponent")
	if not weapon_component:
		missing_components.append("WeaponComponent")
	if not hurtbox_component:
		missing_components.append("HurtboxComponent")
	
	if missing_components.size() > 0:
		push_error("Player: Missing components: " + str(missing_components))

func _connect_component_signals():
	# Health component signals
	if health_component:
		health_component.health_changed.connect(_on_health_changed)
		health_component.health_depleted.connect(_on_player_died)
	
	# Stats component signals for upgrade application
	if stats_component:
		stats_component.stat_changed.connect(_on_stat_changed)

func _setup_collision_components():
	# Complete hitbox/hurtbox integration (addressing feedback issue)
	if hurtbox_component:
		hurtbox_component.damage_received.connect(_on_damage_received)
		hurtbox_component.hit_by_attack.connect(_on_hit_by_attack)

func _setup_camera():
	# Configure Camera2D for proper centering
	if camera:
		camera.enabled = true
		camera.make_current()
		
		# Set very large limits to effectively disable camera boundaries
		# This allows the camera to follow the player freely
		camera.limit_left = -10000
		camera.limit_top = -10000
		camera.limit_right = 10000
		camera.limit_bottom = 10000
		
		print("Player: Camera2D configured and made current")
	else:
		push_warning("Player: Camera2D not found")

func _physics_process(delta: float):
	_handle_movement_input(delta)


func _handle_movement_input(delta: float):
	if not InputManager or not movement_component:
		return
	
	# Get validated movement input
	var movement_input = InputManager.get_movement_vector()
	
	# Apply input validation
	if not _is_movement_input_valid(movement_input):
		return
	
	movement_component.apply_movement_input(movement_input, delta)


func _is_movement_input_valid(input: Vector2) -> bool:
	# Validate input magnitude to prevent malformed/malicious input
	if input.length_squared() > MAX_INPUT_MAGNITUDE_SQUARED:
		return false
	
	return true

func _is_action_input_valid(_action: String) -> bool:
	# Prevent input spam
	var current_frame = Engine.get_process_frames()
	
	if current_frame == last_input_frame:
		input_spam_count += 1
		if input_spam_count > INPUT_SPAM_LIMIT:
			return false
	else:
		input_spam_count = 0
		last_input_frame = current_frame
	
	return true

func gain_experience(amount: int):
	if amount <= 0:
		return
	
	# Apply experience multiplier with overflow protection (addressing feedback issue)
	var multiplier = 1.0
	if stats_component:
		multiplier = stats_component.get_experience_multiplier()
	
	# Use safe integer calculation to prevent overflow
	var safe_amount = mini(amount, MAX_EXPERIENCE - current_experience)
	var actual_amount = int(safe_amount * multiplier)
	
	# Clamp to prevent overflow
	actual_amount = mini(actual_amount, MAX_EXPERIENCE - current_experience)
	
	if actual_amount <= 0:
		return
	
	current_experience += actual_amount
	experience_gained.emit(actual_amount)
	
	# Check for level up
	while current_experience >= experience_to_next_level and current_level < MAX_LEVEL:
		_level_up()

func _level_up():
	current_level += 1
	current_experience -= experience_to_next_level
	
	# Scale experience requirement
	experience_to_next_level = int(experience_to_next_level * 1.2)  # 20% increase per level
	
	level_up.emit()
	
	if AudioManager:
		AudioManager.play_level_up(global_position)
	
	print(EnemyPool.PLAYER_LEVELUP_FORMAT % [current_level, experience_to_next_level])

func apply_upgrade(upgrade_data: Dictionary):
	if not upgrade_data or not stats_component:
		return
	
	print("Player: Applying upgrade: %s" % upgrade_data.get("name", "Unknown"))
	
	# Apply stat changes through stats component
	match upgrade_data.get("type", ""):
		"health":
			var health_bonus = upgrade_data.get("value", 0)
			stats_component.add_flat_bonus("max_health", health_bonus)
			# Heal player when max health increases
			if health_component:
				health_component.set_max_health(stats_component.get_max_health(), false)
		
		"damage":
			var damage_bonus = upgrade_data.get("value", 0.0)
			stats_component.add_percentage_bonus("damage", damage_bonus)
		
		"speed":
			var speed_bonus = upgrade_data.get("value", 0.0)
			stats_component.add_percentage_bonus("speed", speed_bonus)
		
		"attack_speed":
			var attack_speed_bonus = upgrade_data.get("value", 0.0)
			stats_component.add_percentage_bonus("attack_speed", attack_speed_bonus)
		
	
	# Apply updated stats to components
	_apply_stats_to_components()

func _apply_stats_to_components():
	if not stats_component:
		return
	
	# Update health component
	if health_component:
		var new_max_health = stats_component.get_max_health()
		health_component.set_max_health(new_max_health, false)
	
	# Update movement component
	if movement_component:
		var new_speed = stats_component.get_speed()
		movement_component.set_base_speed(new_speed)
	
	# Update weapon component
	if weapon_component:
		# Weapon component will query stats_component automatically
		pass

func _on_health_changed(current_health: int, max_health: int):
	health_changed.emit(current_health, max_health)

func _on_player_died():
	died.emit()
	
	if AudioManager:
		AudioManager.play_player_hit(global_position)
	
	print("Player died!")

func _on_damage_received(_damage: int, _source: Node2D):
	# Handle damage response (screen shake, effects, etc.)
	pass

func _on_hit_by_attack(_attacker: Node2D):
	# Handle being hit by attack (knockback, effects, etc.)  
	pass

func _on_stat_changed(stat_name: String, old_value: float, new_value: float):
	print(EnemyPool.STAT_CHANGE_FORMAT % [stat_name, old_value, new_value])

# Public interface for external systems
func get_level() -> int:
	return current_level

func get_experience() -> int:
	return current_experience

func get_experience_to_next_level() -> int:
	return experience_to_next_level

func get_experience_percentage() -> float:
	if experience_to_next_level <= 0:
		return 1.0
	return float(current_experience) / float(experience_to_next_level)

func get_health_percentage() -> float:
	if health_component:
		return health_component.get_health_percentage()
	return 1.0

func get_current_health() -> int:
	if health_component:
		return health_component.get_health()
	return 0

func get_max_health() -> int:
	if health_component:
		return health_component.get_max_health()
	return 0

func is_alive() -> bool:
	return health_component and not health_component.is_dead()

# Debug information
func get_debug_info() -> Dictionary:
	var info = {
		"level": current_level,
		"experience": current_experience,
		"experience_to_next": experience_to_next_level,
		"experience_percentage": get_experience_percentage(),
		"position": global_position,
		"is_alive": is_alive()
	}
	
	if health_component:
		info["health"] = health_component.get_debug_info()
	
	if movement_component:
		info["movement"] = movement_component.get_debug_info()
	
	if stats_component:
		info["stats"] = stats_component.get_all_stats()
	
	return info