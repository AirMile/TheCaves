extends Node
## Global event bus for decoupled communication between systems
## Provides centralized signal management for game events

# Player events
signal player_damaged(damage: int)
signal player_healed(amount: int) 
signal player_died
signal player_leveled_up
signal player_experience_gained(amount: int)

# Enemy events  
signal enemy_spawned(enemy: Node2D)
signal enemy_died(enemy: Node2D)
signal enemy_damaged(enemy: Node2D, damage: int)

# Wave events
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal wave_enemy_count_changed(remaining: int)

# Weapon events
signal weapon_fired(weapon: Node, projectile: Node2D)
signal weapon_acquired(weapon_type: String)
signal weapon_upgraded(weapon_type: String, level: int)

# Upgrade events
signal upgrade_offered(upgrades: Array)
signal upgrade_selected(upgrade_data: Dictionary)

# Game state events
signal game_started
signal game_paused
signal game_resumed
signal game_over

# Performance events (for debug monitoring)
signal performance_warning(system: String, metric: String, value: float)

# Utility function to emit signals safely with validation
func emit_signal_safe(signal_name: String, args: Array = []) -> bool:
	if has_signal(signal_name):
		match args.size():
			0: emit_signal(signal_name)
			1: emit_signal(signal_name, args[0])
			2: emit_signal(signal_name, args[0], args[1])  
			3: emit_signal(signal_name, args[0], args[1], args[2])
			_: 
				push_warning("EventBus: Too many arguments for signal: " + signal_name)
				return false
		return true
	else:
		push_error("EventBus: Signal does not exist: " + signal_name)
		return false

# Performance monitoring helper
func emit_performance_warning_if(condition: bool, system: String, metric: String, value: float):
	if condition:
		performance_warning.emit(system, metric, value)