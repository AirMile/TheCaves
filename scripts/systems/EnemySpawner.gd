class_name EnemySpawner
extends Node
## Manages enemy spawning using wave configurations and object pooling
## Follows single responsibility principle and uses resource-based configuration

## Spawning configuration
@export var default_wave_config: WaveConfiguration
@export var arena_bounds: Rect2 = Rect2(0, 0, 800, 600)
@export var spawn_margin: float = 50.0

## Current wave state
var current_wave_config: WaveConfiguration
var current_wave_number: int = 0
var is_spawning_active: bool = false
var wave_start_time: float = 0.0
var wave_elapsed_time: float = 0.0

## Spawning timers and counters
var spawn_timer: float = 0.0
var next_spawn_interval: float = 2.0
var enemies_spawned_this_wave: int = 0
var total_enemies_spawned: int = 0

## Active enemy tracking
var active_enemies: Array[Node2D] = []
var enemy_spawn_counts: Dictionary = {}  # Track count per enemy type

## References
var player_ref: Node2D
var arena_ref: Node2D

## Enemy pooling (simple approach for now)
var enemy_scenes: Dictionary = {}
var pooled_enemies: Dictionary = {}

func _ready() -> void:
	add_to_group("spawners")
	_connect_to_event_bus()
	_load_enemy_scenes()
	
	print("EnemySpawner initialized")

func _process(delta: float) -> void:
	if not is_spawning_active:
		return
	
	wave_elapsed_time += delta
	_update_spawning_logic(delta)
	_check_wave_completion()

## Connect to EventBus signals
func _connect_to_event_bus() -> void:
	if not EventBus:
		push_error("EnemySpawner: EventBus autoload not found")
		return
	
	EventBus.entity_died.connect(_on_enemy_died)
	EventBus.game_state_changed.connect(_on_game_state_changed)

## Load enemy scenes for spawning
func _load_enemy_scenes() -> void:
	# For now, we'll create basic enemy scenes programmatically
	# In a full implementation, these would be loaded from .tscn files
	print("EnemySpawner: Loading enemy scenes...")

## Start spawning wave
func start_wave(wave_config: WaveConfiguration, wave_number: int) -> void:
	if not wave_config or not wave_config.is_valid():
		push_error("EnemySpawner: Invalid wave configuration")
		return
	
	current_wave_config = wave_config
	current_wave_number = wave_number
	is_spawning_active = true
	wave_start_time = 0.0
	wave_elapsed_time = 0.0
	enemies_spawned_this_wave = 0
	
	# Reset spawn timer with initial interval
	spawn_timer = 0.0
	_calculate_next_spawn_interval()
	
	print("EnemySpawner: Starting wave %d: %s" % [wave_number, wave_config.wave_name])
	EventBus.wave_started.emit(wave_config, wave_number)

## Stop spawning
func stop_spawning() -> void:
	is_spawning_active = false
	print("EnemySpawner: Spawning stopped")

## Update spawning logic
func _update_spawning_logic(delta: float) -> void:
	spawn_timer += delta
	
	if spawn_timer >= next_spawn_interval:
		_attempt_spawn_enemy()
		spawn_timer = 0.0
		_calculate_next_spawn_interval()

## Attempt to spawn an enemy
func _attempt_spawn_enemy() -> void:
	if not _can_spawn_enemy():
		return
	
	var enemy_data = current_wave_config.get_random_enemy_data()
	if not enemy_data:
		push_warning("EnemySpawner: No valid enemy data found in wave config")
		return
	
	var spawn_position = _get_spawn_position(enemy_data)
	if spawn_position == Vector2.INF:
		push_warning("EnemySpawner: Could not find valid spawn position")
		return
	
	var enemy = _create_enemy(enemy_data)
	if not enemy:
		push_error("EnemySpawner: Failed to create enemy")
		return
	
	_spawn_enemy(enemy, enemy_data, spawn_position)

## Check if we can spawn an enemy
func _can_spawn_enemy() -> bool:
	if not current_wave_config:
		return false
	
	# Check concurrent enemy limit
	if active_enemies.size() >= current_wave_config.max_concurrent_enemies:
		return false
	
	# Check total enemy budget for wave
	if enemies_spawned_this_wave >= current_wave_config.total_enemy_budget:
		return false
	
	# Check wave time limits
	if wave_elapsed_time >= current_wave_config.wave_duration:
		return false
	
	return true

## Create an enemy (simplified for now)
func _create_enemy(enemy_data: EnemyData) -> CharacterBody2D:
	# For now, create simple enemies programmatically
	# In full implementation, this would instantiate from .tscn files
	var enemy = CharacterBody2D.new()
	enemy.name = "Enemy_" + enemy_data.enemy_id
	
	# Add collision
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = enemy_data.collision_size
	collision.shape = shape
	enemy.add_child(collision)
	
	# Add visual representation
	var sprite = Sprite2D.new()
	if enemy_data.sprite_texture:
		sprite.texture = enemy_data.sprite_texture
	else:
		# Create placeholder texture
		var placeholder = PlaceholderTexture2D.new()
		placeholder.size = enemy_data.collision_size
		sprite.texture = placeholder
	
	sprite.modulate = enemy_data.sprite_color
	sprite.scale = enemy_data.sprite_scale
	enemy.add_child(sprite)
	
	# Set collision layers
	enemy.collision_layer = 3  # Enemies
	enemy.collision_mask = 1 | 2 | 4  # Walls, Player, Player Projectiles
	
	# Add basic AI script (simplified)
	enemy.set_script(preload("res://scripts/BasicEnemy.gd"))
	
	# Store enemy data
	enemy.set_meta("enemy_data", enemy_data)
	enemy.set_meta("spawn_time", Time.get_unix_time_from_system())
	
	return enemy

## Spawn enemy at position
func _spawn_enemy(enemy: CharacterBody2D, enemy_data: EnemyData, position: Vector2) -> void:
	# Add to arena
	if arena_ref:
		arena_ref.add_child(enemy)
	else:
		get_tree().current_scene.add_child(enemy)
	
	# Set position
	enemy.global_position = position
	
	# Track enemy
	active_enemies.append(enemy)
	enemies_spawned_this_wave += 1
	total_enemies_spawned += 1
	
	# Update spawn count for this enemy type
	var enemy_id = enemy_data.enemy_id
	if enemy_id in enemy_spawn_counts:
		enemy_spawn_counts[enemy_id] += 1
	else:
		enemy_spawn_counts[enemy_id] = 1
	
	# Connect death signal
	if enemy.has_signal("died"):
		enemy.died.connect(_on_enemy_died_direct.bind(enemy))
	
	# Emit spawn event
	EventBus.enemy_spawned.emit(enemy, enemy_data)
	
	print("EnemySpawner: Spawned %s at %s" % [enemy_data.display_name, position])

## Get valid spawn position
func _get_spawn_position(_enemy_data: EnemyData) -> Vector2:
	if not player_ref:
		# Random edge position if no player reference
		return _get_random_edge_position()
	
	var player_pos = player_ref.global_position
	var attempts = 10
	
	for i in attempts:
		var angle = randf() * TAU
		var distance = randf_range(100.0, 250.0)  # Distance from player
		var position = player_pos + Vector2.from_angle(angle) * distance
		
		# Clamp to arena bounds
		position.x = clamp(position.x, spawn_margin, arena_bounds.size.x - spawn_margin)
		position.y = clamp(position.y, spawn_margin, arena_bounds.size.y - spawn_margin)
		
		# Check if position is valid (not too close to other enemies, etc.)
		if _is_position_valid(position):
			return position
	
	# Fallback to edge position
	return _get_random_edge_position()

## Get random position at arena edge
func _get_random_edge_position() -> Vector2:
	var edge = randi() % 4  # 0=top, 1=right, 2=bottom, 3=left
	
	match edge:
		0:  # Top
			return Vector2(randf() * arena_bounds.size.x, spawn_margin)
		1:  # Right
			return Vector2(arena_bounds.size.x - spawn_margin, randf() * arena_bounds.size.y)
		2:  # Bottom
			return Vector2(randf() * arena_bounds.size.x, arena_bounds.size.y - spawn_margin)
		3:  # Left
			return Vector2(spawn_margin, randf() * arena_bounds.size.y)
		_:
			return Vector2(arena_bounds.size.x * 0.5, spawn_margin)

## Check if spawn position is valid
func _is_position_valid(position: Vector2) -> bool:
	# Simple check - could be expanded with collision detection
	return arena_bounds.has_point(position)

## Calculate next spawn interval with variance
func _calculate_next_spawn_interval() -> void:
	if not current_wave_config:
		next_spawn_interval = 2.0
		return
	
	var base_interval = current_wave_config.spawn_interval
	var variance = current_wave_config.spawn_interval_variance
	var random_variance = randf_range(-variance, variance)
	
	next_spawn_interval = max(0.1, base_interval + random_variance)

## Check if wave is completed
func _check_wave_completion() -> void:
	if not is_spawning_active:
		return
	
	var wave_time_complete = wave_elapsed_time >= current_wave_config.wave_duration
	var enemies_cleared = active_enemies.is_empty()
	var budget_exhausted = enemies_spawned_this_wave >= current_wave_config.total_enemy_budget
	
	if wave_time_complete and enemies_cleared:
		_complete_wave(true)
	elif wave_time_complete and budget_exhausted:
		_complete_wave(false)

## Complete current wave
func _complete_wave(victory: bool) -> void:
	is_spawning_active = false
	print("EnemySpawner: Wave %d completed - Victory: %s" % [current_wave_number, victory])
	EventBus.wave_completed.emit(current_wave_number, victory)

## Set references for dependency injection
func set_player_reference(player: Node2D) -> void:
	player_ref = player
	print("EnemySpawner: Player reference set")

func set_arena_reference(arena: Node2D) -> void:
	arena_ref = arena
	print("EnemySpawner: Arena reference set")

## Event handlers
func _on_enemy_died(enemy: Node2D) -> void:
	_on_enemy_died_direct(enemy)

func _on_enemy_died_direct(enemy: Node2D) -> void:
	var index = active_enemies.find(enemy)
	if index >= 0:
		active_enemies.remove_at(index)
	
	# Clean up enemy
	if is_instance_valid(enemy):
		enemy.queue_free()
	
	EventBus.enemy_despawned.emit(enemy)

func _on_game_state_changed(_old_state: GamePhase.Type, new_state: GamePhase.Type) -> void:
	match new_state:
		GamePhase.Type.GAME_OVER, GamePhase.Type.MENU:
			stop_spawning()
			_cleanup_all_enemies()

## Clean up all active enemies
func _cleanup_all_enemies() -> void:
	for enemy in active_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	active_enemies.clear()

## Public interface
func get_active_enemy_count() -> int:
	return active_enemies.size()

func get_total_spawned() -> int:
	return total_enemies_spawned

func get_wave_progress() -> float:
	if not current_wave_config or current_wave_config.wave_duration <= 0:
		return 0.0
	return wave_elapsed_time / current_wave_config.wave_duration

## Debug information
func get_debug_info() -> Dictionary:
	return {
		"is_spawning": is_spawning_active,
		"current_wave": current_wave_number,
		"wave_time": wave_elapsed_time,
		"active_enemies": active_enemies.size(),
		"enemies_spawned": enemies_spawned_this_wave,
		"total_spawned": total_enemies_spawned,
		"spawn_timer": spawn_timer,
		"next_interval": next_spawn_interval
	}