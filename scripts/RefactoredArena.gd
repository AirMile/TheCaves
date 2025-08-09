class_name RefactoredArena
extends Node2D
## Main arena coordinator that implements dependency injection pattern
## Connects all systems together following Godot best practices

## System references
@onready var arena: Node2D = $Arena
@onready var player: Player = $Arena/Player
@onready var game_manager: Node = $Systems/GameManager
@onready var enemy_spawner: EnemySpawner = $Systems/EnemySpawner
@onready var ui_manager: UIManager = $UIManager

## Configuration (created programmatically to avoid .tres loading issues)
var game_config: GameConfiguration
var starting_wave: WaveConfiguration

func _ready() -> void:
	print("RefactoredArena: Initializing systems...")
	
	# Create resources programmatically
	_create_resources()
	
	# Wait one frame to ensure all systems are ready
	await get_tree().process_frame
	
	_setup_system_dependencies()
	_configure_systems()
	_start_game()
	
	print("RefactoredArena: All systems initialized and connected")

## Create game resources programmatically to avoid .tres loading issues
func _create_resources() -> void:
	print("RefactoredArena: Creating game resources...")
	
	# Create game configuration
	game_config = GameConfiguration.new()
	game_config.config_name = "Default Game Configuration"
	game_config.version = "1.0.0"
	game_config.player_starting_health = 100
	game_config.player_starting_speed = 200.0
	game_config.arena_size = Vector2(800, 600)
	game_config.max_enemies = 150
	game_config.target_fps = 60
	
	# Create enemy data
	var swarm_enemy = EnemyData.new()
	swarm_enemy.enemy_id = "swarm"
	swarm_enemy.display_name = "Swarm Bug"
	swarm_enemy.max_health = 25
	swarm_enemy.base_speed = 120.0
	swarm_enemy.damage = 5
	swarm_enemy.sprite_color = Color.RED
	swarm_enemy.collision_size = Vector2(16, 16)
	swarm_enemy.ai_type = "chase_player"
	swarm_enemy.detection_range = 150.0
	swarm_enemy.attack_range = 20.0
	
	var ranged_enemy = EnemyData.new()
	ranged_enemy.enemy_id = "ranged"
	ranged_enemy.display_name = "Spitter"
	ranged_enemy.max_health = 50
	ranged_enemy.base_speed = 80.0
	ranged_enemy.damage = 12
	ranged_enemy.sprite_color = Color.BLUE
	ranged_enemy.collision_size = Vector2(24, 24)
	ranged_enemy.ai_type = "ranged_attacker"
	ranged_enemy.detection_range = 200.0
	ranged_enemy.attack_range = 150.0
	
	# Create spawn configs
	var swarm_spawn_config = EnemySpawnConfig.new()
	swarm_spawn_config.enemy_data = swarm_enemy
	swarm_spawn_config.spawn_weight = 3.0
	swarm_spawn_config.max_concurrent = 4
	swarm_spawn_config.spawn_distance_from_player = Vector2(100, 200)
	
	var ranged_spawn_config = EnemySpawnConfig.new()
	ranged_spawn_config.enemy_data = ranged_enemy
	ranged_spawn_config.spawn_weight = 1.0
	ranged_spawn_config.max_concurrent = 2
	ranged_spawn_config.spawn_distance_from_player = Vector2(150, 250)
	ranged_spawn_config.min_spawn_time = 10.0
	ranged_spawn_config.max_spawn_count = 3
	
	# Create wave configuration
	starting_wave = WaveConfiguration.new()
	starting_wave.wave_id = "first_wave"
	starting_wave.wave_name = "First Contact"
	starting_wave.wave_duration = 90.0
	starting_wave.spawn_interval = 1.5
	starting_wave.spawn_interval_variance = 0.5
	starting_wave.max_concurrent_enemies = 5
	starting_wave.total_enemy_budget = 20
	starting_wave.enemy_spawn_configs = [swarm_spawn_config, ranged_spawn_config]
	
	print("RefactoredArena: Resources created successfully")

## Setup dependency injection between systems
func _setup_system_dependencies() -> void:
	print("RefactoredArena: Setting up system dependencies...")
	
	# Inject dependencies into ArenaGameManager
	if game_manager:
		game_manager.set_player_reference(player)
		game_manager.set_enemy_spawner_reference(enemy_spawner)
		game_manager.set_ui_manager_reference(ui_manager)
	
	# Inject dependencies into EnemySpawner
	if enemy_spawner:
		enemy_spawner.set_player_reference(player)
		enemy_spawner.set_arena_reference(arena)
	
	print("RefactoredArena: Dependencies injected successfully")

## Configure systems with resources
func _configure_systems() -> void:
	print("RefactoredArena: Configuring systems...")
	
	# Configure ArenaGameManager
	if game_manager and game_config:
		game_manager.game_config = game_config
		game_manager.starting_wave_config = starting_wave
		# Re-validate configuration after assignment
		if game_manager.has_method("_validate_configuration"):
			game_manager._validate_configuration()
	
	# Configure EnemySpawner
	if enemy_spawner:
		enemy_spawner.default_wave_config = starting_wave
		enemy_spawner.arena_bounds = Rect2(0, 0, 800, 600)
		enemy_spawner.spawn_margin = 50.0
	
	print("RefactoredArena: Systems configured successfully")

## Start the game
func _start_game() -> void:
	print("RefactoredArena: Starting game...")
	
	if game_manager:
		game_manager.start_game()
	else:
		push_error("RefactoredArena: ArenaGameManager not found, cannot start game")

## Debug input handling
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):  # Enter key
		_print_debug_info()

## Print debug information about all systems
func _print_debug_info() -> void:
	print("\n=== RefactoredArena Debug Info ===")
	
	if game_manager:
		print("ArenaGameManager:", game_manager.get_debug_info())
	
	if enemy_spawner:
		print("EnemySpawner:", enemy_spawner.get_debug_info())
	
	if ui_manager:
		print("UIManager:", ui_manager.get_debug_info())
	
	if player:
		print("Player:", player.get_debug_info())
	
	if EventBus:
		EventBus.print_debug_info()
	
	print("==================================\n")