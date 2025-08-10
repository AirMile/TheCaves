extends Node
## Global event bus for decoupled communication between systems
## Provides centralized signal management for game events
## Follows Godot best practices for autoload singletons

## Game state management signals
@warning_ignore("unused_signal")
signal game_state_changed(old_state: GamePhase.Type, new_state: GamePhase.Type)
@warning_ignore("unused_signal")
signal game_started
@warning_ignore("unused_signal")
signal game_paused(paused: bool)
@warning_ignore("unused_signal")
signal game_ended(victory: bool)

## Player lifecycle signals
@warning_ignore("unused_signal")
signal player_spawned(player: Node2D)
@warning_ignore("unused_signal")
signal player_died
@warning_ignore("unused_signal")
signal player_respawned(player: Node2D)

## Player stats signals
@warning_ignore("unused_signal")
signal player_health_changed(current: int, maximum: int)
@warning_ignore("unused_signal")
signal player_healed(amount: int, source: Node2D)
@warning_ignore("unused_signal")
signal player_damaged(damage: int, source: Node2D)
@warning_ignore("unused_signal")
signal player_experience_gained(amount: int)
@warning_ignore("unused_signal")
signal player_leveled_up(new_level: int)
@warning_ignore("unused_signal")
signal player_stats_changed(stat_name: String, old_value: float, new_value: float)

## Combat signals
@warning_ignore("unused_signal")
signal damage_dealt(target: Node2D, amount: int, source: Node2D)
@warning_ignore("unused_signal")
signal entity_died(entity: Node2D)
@warning_ignore("unused_signal")
signal projectile_fired(projectile: Node2D, source: Node2D)
@warning_ignore("unused_signal")
signal projectile_hit(projectile: Node2D, target: Node2D)

## Enemy management signals
@warning_ignore("unused_signal")
signal enemy_spawned(enemy: Node2D, enemy_data: EnemyData)
@warning_ignore("unused_signal")
signal enemy_despawned(enemy: Node2D)
@warning_ignore("unused_signal")
signal enemy_target_acquired(enemy: Node2D, target: Node2D)
@warning_ignore("unused_signal")
signal enemy_target_lost(enemy: Node2D)

## Wave management signals
@warning_ignore("unused_signal")
signal wave_started(wave_config: WaveConfiguration, wave_number: int)
@warning_ignore("unused_signal")
signal wave_completed(wave_number: int, victory: bool)
@warning_ignore("unused_signal")
signal wave_progress_updated(enemies_remaining: int, total_enemies: int)

## Weapon system signals
@warning_ignore("unused_signal")
signal weapon_equipped(weapon_data: Dictionary)
@warning_ignore("unused_signal")
signal weapon_unequipped(weapon_type: String)
@warning_ignore("unused_signal")
signal weapon_fired(weapon_type: String, projectile: Node2D)
@warning_ignore("unused_signal")
signal weapon_upgraded(weapon_type: String, new_level: int)

## Upgrade system signals
@warning_ignore("unused_signal")
signal upgrades_offered(available_upgrades: Array[Dictionary])
@warning_ignore("unused_signal")
signal upgrade_selected(upgrade_data: Dictionary)
@warning_ignore("unused_signal")
signal upgrade_applied(player: Node2D, upgrade_data: Dictionary)

## UI signals
@warning_ignore("unused_signal")
signal ui_element_focused(element: Control)
@warning_ignore("unused_signal")
signal ui_element_clicked(element: Control, button: int)
@warning_ignore("unused_signal")
signal ui_notification_requested(message: String, type: String, duration: float)

## Audio signals
@warning_ignore("unused_signal")
signal sound_requested(sound: AudioStream, position: Vector2, volume: float)
@warning_ignore("unused_signal")
signal music_change_requested(music: AudioStream, fade_duration: float)

## Performance monitoring signals
@warning_ignore("unused_signal")
signal performance_warning(system: String, metric: String, value: float, threshold: float)
@warning_ignore("unused_signal")
signal fps_changed(current_fps: int, target_fps: int)
@warning_ignore("unused_signal")
signal memory_warning(used_memory: int, available_memory: int)

## Debug signals
@warning_ignore("unused_signal")
signal debug_info_updated(debug_data: Dictionary)
@warning_ignore("unused_signal")
signal debug_draw_requested(draw_type: String, data: Dictionary)

## Performance monitoring thresholds
const FPS_WARNING_THRESHOLD: int = 50
const MEMORY_WARNING_THRESHOLD: int = 400_000_000  # 400MB
const ENTITY_COUNT_WARNING_THRESHOLD: int = 200

## Signal emission statistics (for debugging)
var signal_stats: Dictionary = {}
var debug_enabled: bool = false

func _ready() -> void:
	print("EventBus initialized - Centralized event management active")

## Utility function to emit signals safely with validation and statistics
func emit_signal_safe(signal_name: String, args: Array = []) -> bool:
	if not has_signal(signal_name):
		push_error("EventBus: Signal does not exist: %s" % signal_name)
		return false
	
	# Update statistics
	if debug_enabled:
		_update_signal_stats(signal_name)
	
	# Emit signal based on argument count using proper Godot API
	match args.size():
		0: 
			emit_signal(signal_name)
		1: 
			emit_signal(signal_name, args[0])
		2: 
			emit_signal(signal_name, args[0], args[1])
		3: 
			emit_signal(signal_name, args[0], args[1], args[2])
		4:
			emit_signal(signal_name, args[0], args[1], args[2], args[3])
		_: 
			push_warning("EventBus: Too many arguments (%d) for signal: %s" % [args.size(), signal_name])
			return false
	
	return true

## Performance monitoring helper with threshold checking
func emit_performance_warning_if(condition: bool, system: String, metric: String, value: float, threshold: float = 0.0) -> void:
	if condition:
		performance_warning.emit(system, metric, value, threshold)
		if debug_enabled:
			print("Performance Warning - %s.%s: %.2f (threshold: %.2f)" % [system, metric, value, threshold])

## Monitor FPS and emit warnings if below threshold
func monitor_fps(current_fps: int) -> void:
	fps_changed.emit(current_fps, Engine.get_frames_per_second())
	if current_fps < FPS_WARNING_THRESHOLD:
		emit_performance_warning_if(true, "Renderer", "fps", current_fps, FPS_WARNING_THRESHOLD)

## Monitor memory usage
func monitor_memory(used_memory: int) -> void:
	if used_memory > MEMORY_WARNING_THRESHOLD:
		# Capability-based detection: check if memory info is actually available
		var available_memory = -1
		var memory_info = OS.get_memory_info()
		
		# Check if the dictionary has the "available" key and it's valid
		if memory_info.has("available"):
			var mem_value = memory_info.get("available", -1)
			if mem_value > 0:
				available_memory = mem_value
		
		memory_warning.emit(used_memory, available_memory)

## Get signal emission statistics for debugging
func get_signal_stats() -> Dictionary:
	return signal_stats.duplicate()

## Reset signal statistics
func reset_signal_stats() -> void:
	signal_stats.clear()

## Enable/disable debug mode
func set_debug_enabled(enabled: bool) -> void:
	debug_enabled = enabled
	if enabled:
		print("EventBus debug mode enabled")
	else:
		print("EventBus debug mode disabled")

## Update signal emission statistics
func _update_signal_stats(signal_name: String) -> void:
	if signal_name in signal_stats:
		signal_stats[signal_name] += 1
	else:
		signal_stats[signal_name] = 1

## Print debug information about current signal usage
func print_debug_info() -> void:
	if not debug_enabled:
		print("EventBus debug mode is disabled")
		return
	
	print("=== EventBus Debug Information ===")
	print("Total signals defined: %d" % get_signal_list().size())
	print("Signal emission statistics:")
	
	var sorted_stats = []
	for signal_name in signal_stats:
		sorted_stats.append([signal_name, signal_stats[signal_name]])
	
	sorted_stats.sort_custom(func(a, b): return a[1] > b[1])
	
	for stat in sorted_stats:
		print("  %s: %d emissions" % [stat[0], stat[1]])
	
	print("=====================================")
