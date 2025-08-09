class_name ArenaGameManager
extends Node
## Manages overall game state and coordinates between systems
## Implements IGameState interface and follows single responsibility principle

## Game configuration
@export var game_config: GameConfiguration
@export var starting_wave_config: WaveConfiguration

## Current game state
var current_state: GamePhase.Type = GamePhase.Type.MENU
var is_game_paused: bool = false

## Game statistics
var current_wave: int = 0
var game_time: float = 0.0
var enemies_killed: int = 0
var player_level: int = 1

## System references (injected via dependency injection)
var player_ref: Node2D
var enemy_spawner_ref: Node
var ui_manager_ref: Node

func _ready() -> void:
	add_to_group("managers")
	_connect_to_event_bus()
	_validate_configuration()
	
	print("ArenaGameManager initialized")

func _process(delta: float) -> void:
	if current_state == GamePhase.Type.PLAYING and not is_game_paused:
		game_time += delta
		_update_game_logic(delta)

## Connect to EventBus signals
func _connect_to_event_bus() -> void:
	if not EventBus:
		push_error("ArenaGameManager: EventBus autoload not found")
		return
	
	# Connect to relevant signals
	EventBus.player_died.connect(_on_player_died)
	EventBus.entity_died.connect(_on_enemy_died)
	EventBus.wave_completed.connect(_on_wave_completed)
	EventBus.player_leveled_up.connect(_on_player_leveled_up)

## Validate game configuration
func _validate_configuration() -> void:
	if not game_config:
		push_error("ArenaGameManager: No game configuration assigned")
		game_config = GameConfiguration.new()  # Create default
	
	if not game_config.is_valid():
		push_error("ArenaGameManager: Invalid game configuration")

## Update game logic during play
func _update_game_logic(delta: float) -> void:
	# Check if we need to start a new wave
	if enemy_spawner_ref and enemy_spawner_ref.has_method("get_active_enemy_count"):
		var active_enemies = enemy_spawner_ref.get_active_enemy_count()
		EventBus.wave_progress_updated.emit(active_enemies, enemy_spawner_ref.get_total_spawned())

## Implement IGameState interface methods
func set_game_state(new_state: GamePhase.Type) -> void:
	if current_state == new_state:
		return
	
	var old_state = current_state
	current_state = new_state
	
	# Emit state change
	EventBus.game_state_changed.emit(old_state, new_state)
	
	# Handle state transitions
	_handle_state_transition(old_state, new_state)
	
	print("ArenaGameManager: State changed from %s to %s" % [
		GamePhase.Type.keys()[old_state],
		GamePhase.Type.keys()[new_state]
	])

func get_game_state() -> GamePhase.Type:
	return current_state

func start_game() -> void:
	if current_state != GamePhase.Type.MENU:
		push_warning("ArenaGameManager: Cannot start game from state: %s" % GamePhase.Type.keys()[current_state])
		return
	
	_reset_game_state()
	set_game_state(GamePhase.Type.PLAYING)
	EventBus.game_started.emit()

func end_game(victory: bool = false) -> void:
	if current_state == GamePhase.Type.GAME_OVER:
		return
	
	var end_state = GamePhase.Type.VICTORY if victory else GamePhase.Type.GAME_OVER
	set_game_state(end_state)
	EventBus.game_ended.emit(victory)

func set_paused(paused: bool) -> void:
	if is_game_paused == paused:
		return
	
	is_game_paused = paused
	get_tree().paused = paused
	EventBus.game_paused.emit(paused)

func is_paused() -> bool:
	return is_game_paused

func is_playing() -> bool:
	return current_state == GamePhase.Type.PLAYING and not is_game_paused

## Handle state transitions
func _handle_state_transition(old_state: GamePhase.Type, new_state: GamePhase.Type) -> void:
	match new_state:
		GamePhase.Type.PLAYING:
			_start_gameplay()
		GamePhase.Type.PAUSED:
			_pause_gameplay()
		GamePhase.Type.GAME_OVER, GamePhase.Type.VICTORY:
			_end_gameplay()

## Start gameplay systems
func _start_gameplay() -> void:
	# Start first wave if enemy spawner is available
	if enemy_spawner_ref and enemy_spawner_ref.has_method("start_wave"):
		var wave_config = starting_wave_config if starting_wave_config else _get_default_wave()
		enemy_spawner_ref.start_wave(wave_config, 1)
		current_wave = 1
		EventBus.wave_started.emit(wave_config, current_wave)

## Pause gameplay systems
func _pause_gameplay() -> void:
	# Pause could be implemented with specific system calls
	pass

## End gameplay and cleanup
func _end_gameplay() -> void:
	# Stop spawning, cleanup systems
	if enemy_spawner_ref and enemy_spawner_ref.has_method("stop_spawning"):
		enemy_spawner_ref.stop_spawning()

## Reset game state for new game
func _reset_game_state() -> void:
	game_time = 0.0
	current_wave = 0
	enemies_killed = 0
	player_level = 1

## Get default wave configuration if none provided
func _get_default_wave() -> WaveConfiguration:
	var wave = WaveConfiguration.new()
	wave.wave_id = "default_wave_1"
	wave.wave_name = "First Wave"
	wave.wave_duration = 60.0
	wave.spawn_interval = 2.0
	wave.max_concurrent_enemies = 5
	return wave

## System reference injection (dependency injection pattern)
func set_player_reference(player: Node2D) -> void:
	player_ref = player
	print("GameManager: Player reference set")

func set_enemy_spawner_reference(spawner: Node) -> void:
	enemy_spawner_ref = spawner
	print("GameManager: Enemy spawner reference set")

func set_ui_manager_reference(ui_manager: Node) -> void:
	ui_manager_ref = ui_manager
	print("GameManager: UI manager reference set")

## Event handlers
func _on_player_died() -> void:
	end_game(false)

func _on_enemy_died(enemy: Node2D) -> void:
	enemies_killed += 1

func _on_wave_completed(wave_number: int, victory: bool) -> void:
	if victory:
		current_wave += 1
		print("GameManager: Wave %d completed, starting wave %d" % [wave_number, current_wave])
		# Start next wave logic could go here

func _on_player_leveled_up(new_level: int) -> void:
	player_level = new_level
	print("GameManager: Player reached level %d" % new_level)

## Debug information
func get_debug_info() -> Dictionary:
	return {
		"current_state": GamePhase.Type.keys()[current_state],
		"is_paused": is_game_paused,
		"game_time": game_time,
		"current_wave": current_wave,
		"enemies_killed": enemies_killed,
		"player_level": player_level
	}
