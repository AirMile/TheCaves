extends Node

signal player_died
signal player_health_changed(new_health: int, max_health: int)
signal player_leveled_up(new_level: int)
signal player_gained_experience(amount: int)
signal player_stats_changed

signal enemy_died(enemy_position: Vector2, enemy_type: String)
signal enemy_spawned(enemy: Node2D)
signal enemy_damaged(enemy: Node2D, damage: int)

signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal wave_enemy_count_changed(remaining_enemies: int)

signal weapon_fired(weapon_name: String, position: Vector2, direction: Vector2)
signal projectile_hit(target: Node2D, damage: int)

signal pickup_collected(pickup_type: String, value: int, position: Vector2)
signal upgrade_selected(upgrade_id: String)
signal upgrade_panel_opened(available_upgrades: Array)
signal upgrade_panel_closed

signal game_started
signal game_paused
signal game_resumed
signal game_over(final_score: int, wave_reached: int)

signal debug_toggle_requested
signal performance_stats_updated(fps: int, enemies: int, projectiles: int, collision_pairs: int)

func _ready():
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	
	if OS.is_debug_build():
		print("[EventBus] Initialized - Event system ready")

func emit_with_debug(signal_name: String, args: Array = []):
	if OS.is_debug_build():
		print("[EventBus] Emitting: %s with args: %s" % [signal_name, str(args)])
	
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
		5:
			emit_signal(signal_name, args[0], args[1], args[2], args[3], args[4])