extends Node2D
## Test arena script that spawns enemies and shows basic UI

@onready var player: Player = $Player

var spawn_timer: float = 0.0
var spawn_interval: float = 1.0  # Faster spawning for testing
var max_enemies: int = 10
var current_enemies: int = 0

func _ready():
	# Start spawning enemies after a delay
	await get_tree().create_timer(1.0).timeout
	_start_enemy_spawning()

func _process(delta: float):
	_handle_enemy_spawning(delta)

func _handle_enemy_spawning(delta: float):
	if current_enemies >= max_enemies:
		return
	
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		_spawn_random_enemy()

func _spawn_random_enemy():
	if not EnemyPool:
		return
	
	var enemy_types = ["swarm", "ranged", "tank"]
	var random_type = enemy_types[randi() % enemy_types.size()]
	
	var enemy = EnemyPool.get_enemy(random_type)
	if enemy:
		# Position enemy at random edge of arena
		var spawn_pos = _get_random_spawn_position()
		enemy.global_position = spawn_pos
		current_enemies += 1
		
		# Connect enemy death signal to update counter (signal already exists in BasicEnemy)
		if not enemy.is_connected("died", _on_enemy_died):
			enemy.connect("died", _on_enemy_died)
		
		print("TestArena: Spawned %s enemy at %s" % [random_type, spawn_pos])

func _get_random_spawn_position() -> Vector2:
	var arena_center = Vector2(400, 300)
	var spawn_distance = 150.0  # Reduced to ensure enemies are visible
	
	var angle = randf() * TAU
	var spawn_pos = arena_center + Vector2.from_angle(angle) * spawn_distance
	
	# Ensure spawn position is within arena bounds (with some margin)
	spawn_pos.x = clamp(spawn_pos.x, 50, 750)
	spawn_pos.y = clamp(spawn_pos.y, 50, 550)
	
	return spawn_pos

func _on_enemy_died():
	current_enemies -= 1

func _start_enemy_spawning():
	print("TestArena: Starting enemy spawning - EnemyPool available: %s" % (EnemyPool != null))
	if EnemyPool:
		print("TestArena: EnemyPool stats: %s" % EnemyPool.get_pool_stats())

func _physics_process(_delta: float):
	# Update main UI
	var enemy_counter = get_node_or_null("UI/TopLeftLabels/EnemyCounter")
	if enemy_counter:
		enemy_counter.text = "Enemies: %d/%d" % [current_enemies, max_enemies]
	
	# Update debug panel if visible
	var debug_panel = get_node_or_null("DebugPanel")
	if debug_panel and debug_panel.visible:
		var enemies_label = debug_panel.get_node_or_null("VBox/Enemies")
		if enemies_label:
			enemies_label.text = "Active Enemies: %d" % current_enemies