extends Node

enum GameState {
	MENU,
	PLAYING,
	PAUSED,
	UPGRADING,
	GAME_OVER
}

var current_state: GameState = GameState.MENU
var previous_state: GameState = GameState.MENU

var current_wave: int = 0
var max_waves: int = 20
var enemies_remaining: int = 0
var wave_timer: float = 0.0
var wave_duration: float = 30.0  # Base wave duration

var player_level: int = 1
var player_experience: int = 0
var player_experience_to_next: int = 100
var total_score: int = 0

var run_time: float = 0.0
var game_speed: float = 1.0

var statistics: Dictionary = {
	"enemies_killed": 0,
	"damage_dealt": 0,
	"damage_taken": 0,
	"pickups_collected": 0,
	"waves_completed": 0,
	"upgrades_selected": 0
}

var available_upgrades: Array = []
var player_upgrades: Dictionary = {}

@onready var player_reference: Node2D

func _ready():
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	
	EventBus.game_started.connect(_on_game_started)
	EventBus.game_paused.connect(_on_game_paused)
	EventBus.game_resumed.connect(_on_game_resumed)
	EventBus.game_over.connect(_on_game_over)
	
	EventBus.player_died.connect(_on_player_died)
	EventBus.player_leveled_up.connect(_on_player_leveled_up)
	EventBus.player_gained_experience.connect(_on_player_gained_experience)
	
	EventBus.enemy_died.connect(_on_enemy_died)
	EventBus.wave_completed.connect(_on_wave_completed)
	EventBus.upgrade_selected.connect(_on_upgrade_selected)
	
	_find_player_reference()
	
	if OS.is_debug_build():
		print("[GameManager] Initialized - Ready for game sessions")

func _process(delta):
	match current_state:
		GameState.PLAYING:
			run_time += delta
			wave_timer += delta
		GameState.PAUSED, GameState.UPGRADING:
			pass

func _find_player_reference():
	call_deferred("_search_for_player")

func _search_for_player():
	var player_nodes = get_tree().get_nodes_in_group("player")
	if player_nodes.size() > 0:
		player_reference = player_nodes[0]

func start_game():
	current_state = GameState.PLAYING
	current_wave = 1
	player_level = 1
	player_experience = 0
	total_score = 0
	run_time = 0.0
	
	statistics = {
		"enemies_killed": 0,
		"damage_dealt": 0,
		"damage_taken": 0,
		"pickups_collected": 0,
		"waves_completed": 0,
		"upgrades_selected": 0
	}
	
	player_upgrades.clear()
	
	EventBus.game_started.emit()
	start_wave(current_wave)
	
	AudioManager.play_music("game_theme")

func pause_game():
	if current_state == GameState.PLAYING:
		previous_state = current_state
		current_state = GameState.PAUSED
		get_tree().paused = true
		EventBus.game_paused.emit()

func resume_game():
	if current_state == GameState.PAUSED:
		current_state = previous_state
		get_tree().paused = false
		EventBus.game_resumed.emit()

func end_game():
	current_state = GameState.GAME_OVER
	get_tree().paused = false
	
	EventBus.game_over.emit(total_score, current_wave)
	
	EnemyPool.deactivate_all_enemies()
	ProjectileManager.deactivate_all_projectiles()
	
	AudioManager.stop_music()

func start_wave(wave_number: int):
	current_wave = wave_number
	wave_timer = 0.0
	
	var wave_config = get_wave_config(wave_number)
	enemies_remaining = wave_config.total_enemies
	
	EventBus.wave_started.emit(wave_number)
	EventBus.wave_enemy_count_changed.emit(enemies_remaining)

func get_wave_config(wave_number: int) -> Dictionary:
	var base_enemies = 10
	var enemies_per_wave = 5
	var total_enemies = base_enemies + (wave_number - 1) * enemies_per_wave
	
	var swarm_ratio = 0.6
	var ranged_ratio = 0.3
	var tank_ratio = 0.1
	
	if wave_number >= 10:
		swarm_ratio = 0.5
		ranged_ratio = 0.35
		tank_ratio = 0.15
	
	return {
		"total_enemies": total_enemies,
		"swarm_count": int(total_enemies * swarm_ratio),
		"ranged_count": int(total_enemies * ranged_ratio),
		"tank_count": int(total_enemies * tank_ratio),
		"spawn_rate": max(0.5, 2.0 - wave_number * 0.1),
		"difficulty_modifier": 1.0 + (wave_number - 1) * 0.15
	}

func _on_game_started():
	if OS.is_debug_build():
		print("[GameManager] Game started - Wave 1 beginning")

func _on_game_paused():
	if OS.is_debug_build():
		print("[GameManager] Game paused")

func _on_game_resumed():
	if OS.is_debug_build():
		print("[GameManager] Game resumed")

func _on_game_over(final_score: int, wave_reached: int):
	if OS.is_debug_build():
		print("[GameManager] Game over - Score: %d, Wave: %d" % [final_score, wave_reached])

func _on_player_died():
	end_game()

func _on_player_leveled_up(new_level: int):
	player_level = new_level
	
	current_state = GameState.UPGRADING
	get_tree().paused = true
	
	_generate_upgrade_options()
	EventBus.upgrade_panel_opened.emit(available_upgrades)

func _on_player_gained_experience(amount: int):
	player_experience += amount
	total_score += amount
	
	var level_up_exp = get_experience_for_level(player_level + 1)
	if player_experience >= level_up_exp:
		player_experience = level_up_exp
		EventBus.player_leveled_up.emit(player_level + 1)

func _on_enemy_died(enemy_position: Vector2, enemy_type: String):
	enemies_remaining = max(0, enemies_remaining - 1)
	statistics.enemies_killed += 1
	
	EventBus.wave_enemy_count_changed.emit(enemies_remaining)
	
	if enemies_remaining <= 0:
		EventBus.wave_completed.emit(current_wave)

func _on_wave_completed(wave_number: int):
	statistics.waves_completed += 1
	
	if wave_number >= max_waves:
		end_game()
	else:
		call_deferred("start_wave", wave_number + 1)

func _on_upgrade_selected(upgrade_id: String):
	if available_upgrades.has(upgrade_id):
		if not player_upgrades.has(upgrade_id):
			player_upgrades[upgrade_id] = 0
		player_upgrades[upgrade_id] += 1
		
		statistics.upgrades_selected += 1
		
		current_state = GameState.PLAYING
		get_tree().paused = false
		
		EventBus.upgrade_panel_closed.emit()

func _generate_upgrade_options():
	var all_upgrades = [
		"damage_boost", "fire_rate_boost", "speed_boost",
		"health_boost", "experience_boost", "projectile_count",
		"dash_cooldown", "pickup_range", "critical_chance"
	]
	
	available_upgrades.clear()
	for i in range(3):
		if all_upgrades.size() > 0:
			var upgrade = all_upgrades.pick_random()
			available_upgrades.append(upgrade)
			all_upgrades.erase(upgrade)

func get_experience_for_level(level: int) -> int:
	return int(100 * pow(1.2, level - 1))

func get_current_state() -> GameState:
	return current_state

func is_game_active() -> bool:
	return current_state == GameState.PLAYING

func is_game_paused() -> bool:
	return current_state == GameState.PAUSED or current_state == GameState.UPGRADING

func get_game_stats() -> Dictionary:
	return {
		"current_wave": current_wave,
		"player_level": player_level,
		"run_time": run_time,
		"total_score": total_score,
		"enemies_remaining": enemies_remaining,
		"statistics": statistics.duplicate()
	}

func add_score(points: int):
	total_score += points