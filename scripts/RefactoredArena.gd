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

## Configuration
@export var game_config: GameConfiguration
@export var starting_wave: WaveConfiguration

func _ready() -> void:
	print("RefactoredArena: Initializing systems...")
	
	# Wait one frame to ensure all systems are ready
	await get_tree().process_frame
	
	_setup_system_dependencies()
	_configure_systems()
	_start_game()
	
	print("RefactoredArena: All systems initialized and connected")

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