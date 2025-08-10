extends Node
## Central game state management and progression system
## Handles waves, scoring, upgrades, and overall game flow

# Game state
enum GameState { MENU, PLAYING, PAUSED, UPGRADING, GAME_OVER }
var current_state: GameState = GameState.MENU

# Wave system
var current_wave: int = 0
var max_waves: int = 20
var enemies_remaining_in_wave: int = 0
var wave_timer: float = 0.0
var wave_duration: float = 60.0  # 1 minute per wave

# Scoring and progression
var score: int = 0
var high_score: int = 0
var run_time: float = 0.0

# Upgrade system
var pending_upgrades: Array[Dictionary] = []
var upgrade_choices_count: int = 3

# Performance monitoring
var performance_metrics: Dictionary = {
	"enemies_active": 0,
	"projectiles_active": 0,
	"collision_pairs": 0,
	"fps": 60
}

# Performance thresholds and warnings
const COLLISION_PAIRS_WARNING: int = 5000
const FPS_WARNING_THRESHOLD: int = 55
var performance_warnings_count: int = 0

func _ready():
	# Connect to EventBus
	if EventBus:
		EventBus.connect("player_died", _on_player_died)
		EventBus.connect("entity_died", _on_enemy_died)
		EventBus.connect("wave_completed", _on_wave_completed)
		EventBus.connect("upgrade_selected", _on_upgrade_selected)
	
	# Load high score
	_load_high_score()

func _process(delta: float):
	if current_state == GameState.PLAYING:
		_update_game_time(delta)
		_update_wave_timer(delta)
		_update_performance_metrics()

func start_game():
	if current_state != GameState.MENU:
		return
	
	current_state = GameState.PLAYING
	current_wave = 1
	score = 0
	run_time = 0.0
	
	# Reset performance metrics
	performance_metrics = {
		"enemies_active": 0,
		"projectiles_active": 0, 
		"collision_pairs": 0,
		"fps": 60
	}
	
	if EventBus:
		EventBus.game_started.emit()
	
	start_wave(current_wave)
	print("GameManager: Game started")

func start_wave(wave_number: int):
	current_wave = wave_number
	wave_timer = wave_duration
	
	# Calculate enemies for this wave - progressive difficulty
	var base_enemies = 15
	var additional_per_wave = 3
	enemies_remaining_in_wave = base_enemies + (wave_number - 1) * additional_per_wave
	enemies_remaining_in_wave = mini(enemies_remaining_in_wave, 80)  # Cap at pool limit
	
	if EventBus:
		EventBus.wave_started.emit(wave_number)
		EventBus.wave_enemy_count_changed.emit(enemies_remaining_in_wave)
	
	print("GameManager: Wave %d started with %d enemies" % [wave_number, enemies_remaining_in_wave])
	
	# Start spawning enemies
	_spawn_wave_enemies()

func _spawn_wave_enemies():
	# Simple spawning pattern - in production this would be more sophisticated
	var enemies_to_spawn = enemies_remaining_in_wave
	
	# Distribute enemy types based on wave progression
	var swarm_percent = 0.6  # 60% swarm
	var ranged_percent = 0.25  # 25% ranged
	var _tank_percent = 0.15  # 15% tank
	
	# Later waves have more variety
	if current_wave > 10:
		swarm_percent = 0.5
		ranged_percent = 0.3
		_tank_percent = 0.2
	
	var swarm_count = int(enemies_to_spawn * swarm_percent)
	var ranged_count = int(enemies_to_spawn * ranged_percent)  
	var tank_count = enemies_to_spawn - swarm_count - ranged_count
	
	# Spawn enemies (placeholder - in production would have proper spawn positions)
	_spawn_enemies("swarm", swarm_count)
	_spawn_enemies("ranged", ranged_count)
	_spawn_enemies("tank", tank_count)

func _spawn_enemies(enemy_type: String, count: int):
	if not EnemyPool:
		push_error("GameManager: EnemyPool not available")
		return
	
	for i in count:
		var enemy = EnemyPool.get_enemy(enemy_type)
		if enemy:
			# Set random spawn position around arena perimeter (placeholder)
			var spawn_angle = randf() * TAU
			var spawn_distance = 400.0
			var spawn_pos = Vector2.from_angle(spawn_angle) * spawn_distance
			enemy.global_position = spawn_pos

func _update_game_time(delta: float):
	run_time += delta

func _update_wave_timer(delta: float):
	wave_timer -= delta
	
	# Check if wave time expired
	if wave_timer <= 0.0 and enemies_remaining_in_wave > 0:
		# Force end wave if enemies remain but time is up
		complete_wave()

func _update_performance_metrics():
	# Update performance tracking
	performance_metrics["fps"] = Engine.get_frames_per_second()
	
	if EnemyPool:
		performance_metrics["enemies_active"] = EnemyPool.get_active_count()
	
	if ProjectileManager:
		performance_metrics["projectiles_active"] = ProjectileManager.get_active_count()
	
	performance_metrics["collision_pairs"] = Performance.get_monitor(Performance.PHYSICS_2D_COLLISION_PAIRS)
	
	# Check for performance issues and emit warnings
	if EventBus:
		var collision_pairs = performance_metrics["collision_pairs"]
		var fps = performance_metrics["fps"]
		
		# FPS warning
		if fps < FPS_WARNING_THRESHOLD:
			EventBus.emit_performance_warning_if(true, "GameManager", "fps", fps)
		
		# Collision pairs warning
		if collision_pairs > COLLISION_PAIRS_WARNING:
			EventBus.emit_performance_warning_if(true, "GameManager", "collision_pairs", collision_pairs)
			performance_warnings_count += 1

func complete_wave():
	if EventBus:
		EventBus.wave_completed.emit(current_wave)
	
	# Award score for wave completion
	var wave_bonus = current_wave * 1000
	add_score(wave_bonus)
	
	# Check if game complete
	if current_wave >= max_waves:
		_game_complete()
		return
	
	# Offer upgrades between waves
	_offer_upgrades()

func _offer_upgrades():
	current_state = GameState.UPGRADING
	
	# Generate upgrade options (placeholder system)
	pending_upgrades = _generate_upgrade_options()
	
	if EventBus:
		EventBus.upgrade_offered.emit(pending_upgrades)
	
	print("GameManager: Offering upgrades for wave completion")

func _generate_upgrade_options() -> Array[Dictionary]:
	var upgrades: Array[Dictionary] = []
	var possible_upgrades = [
		{"type": "health", "name": "Health Boost", "description": "+20 Max Health", "value": 20},
		{"type": "damage", "name": "Damage Up", "description": "+15% Damage", "value": 0.15},
		{"type": "speed", "name": "Speed Boost", "description": "+10% Movement Speed", "value": 0.1},
		{"type": "attack_speed", "name": "Attack Speed", "description": "+20% Attack Speed", "value": 0.2},
		{"type": "dash_cooldown", "name": "Quick Dash", "description": "-25% Dash Cooldown", "value": 0.25}
	]
	
	# Select random upgrades
	for i in upgrade_choices_count:
		if possible_upgrades.size() > 0:
			var upgrade = possible_upgrades.pick_random()
			upgrades.append(upgrade)
			possible_upgrades.erase(upgrade)
	
	return upgrades

func select_upgrade(upgrade_index: int):
	if current_state != GameState.UPGRADING or upgrade_index >= pending_upgrades.size():
		return
	
	var selected_upgrade = pending_upgrades[upgrade_index]
	
	if EventBus:
		EventBus.upgrade_selected.emit(selected_upgrade)
	
	# Continue to next wave
	current_state = GameState.PLAYING
	start_wave(current_wave + 1)

func _on_player_died():
	_game_over()

func _on_enemy_died(enemy: Node2D):
	enemies_remaining_in_wave -= 1
	
	# Award points for enemy kill
	var enemy_type = enemy.get_meta("enemy_type", "swarm")
	var points = _get_enemy_points(enemy_type)
	add_score(points)
	
	if EventBus:
		EventBus.wave_enemy_count_changed.emit(enemies_remaining_in_wave)
	
	# Check if wave complete
	if enemies_remaining_in_wave <= 0:
		complete_wave()

func _get_enemy_points(enemy_type: String) -> int:
	match enemy_type:
		"swarm": return 10
		"ranged": return 25
		"tank": return 50
		"boss": return 200
		_: return 15

func _on_wave_completed(wave_number: int):
	print("GameManager: Wave %d completed" % wave_number)

func _on_upgrade_selected(upgrade_data: Dictionary):
	print("GameManager: Upgrade selected: %s" % upgrade_data.get("name", "Unknown"))

func add_score(points: int):
	# Clamp to prevent integer overflow as mentioned in feedback
	var max_safe_score = 2147483647 - 100000  # Leave buffer
	if score < max_safe_score:
		score = mini(score + points, max_safe_score)
	
	# Update high score
	if score > high_score:
		high_score = score
		_save_high_score()

func _game_over():
	current_state = GameState.GAME_OVER
	
	if EventBus:
		EventBus.game_over.emit()
	
	print("GameManager: Game Over - Final Score: %d, Runtime: %.1fs" % [score, run_time])

func _game_complete():
	# Player completed all waves
	var completion_bonus = 50000
	add_score(completion_bonus)
	_game_over()

func pause_game():
	if current_state == GameState.PLAYING:
		current_state = GameState.PAUSED
		get_tree().paused = true
		
		if EventBus:
			EventBus.game_paused.emit()

func resume_game():
	if current_state == GameState.PAUSED:
		current_state = GameState.PLAYING
		get_tree().paused = false
		
		if EventBus:
			EventBus.game_resumed.emit()

# Persistence
func _save_high_score():
	# In production would save to user settings
	pass

func _load_high_score():
	# In production would load from user settings
	high_score = 0

# Public getters for UI
func get_current_wave() -> int:
	return current_wave

func get_enemies_remaining() -> int:
	return enemies_remaining_in_wave

func get_wave_time_remaining() -> float:
	return max(0.0, wave_timer)

func get_score() -> int:
	return score

func get_high_score() -> int:
	return high_score

func get_run_time() -> float:
	return run_time

func get_performance_metrics() -> Dictionary:
	return performance_metrics.duplicate()

func is_game_active() -> bool:
	return current_state == GameState.PLAYING