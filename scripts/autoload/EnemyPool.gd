extends Node
## High-performance enemy pooling system for 150 enemies
## Provides zero runtime allocation for optimal performance

# Pool sizes based on enemy types and expected spawn patterns
const POOL_SIZES: Dictionary = {
	"swarm": 80,    # Small, numerous enemies - 53% of pool
	"ranged": 40,   # Medium count ranged attackers - 27% of pool
	"tank": 20,     # Few but heavy enemies - 13% of pool  
	"boss": 10      # Rare spawns and mini-bosses - 7% of pool
}

# Total verification
const EXPECTED_TOTAL: int = 150

# Pool storage and tracking
var enemy_pools: Dictionary = {}
var active_enemies: Array[Node2D] = []
var total_spawned: int = 0

# Performance monitoring
var peak_active_count: int = 0
var pool_exhaustion_warnings: int = 0

# Cached format strings for performance
const POOL_CREATE_FORMAT: String = "EnemyPool: Creating %d %s enemies"
const POOL_VERIFY_FORMAT: String = "EnemyPool: Pool configuration verified. Total enemies: %d"
const POOL_MISMATCH_FORMAT: String = "EnemyPool: Pool size mismatch. Expected: %d, Calculated: %d"
const PLAYER_INIT_FORMAT: String = "Player initialized - Level: %d, Health: %d"
const PLAYER_LEVELUP_FORMAT: String = "Player leveled up! Level: %d, Exp to next: %d"
const STAT_CHANGE_FORMAT: String = "Player stat changed: %s %f -> %f"

func _ready():
	_verify_pool_configuration()
	_initialize_pools()
	
	# Connect to EventBus for monitoring
	if EventBus:
		EventBus.connect("entity_died", _on_enemy_died)

func _verify_pool_configuration():
	var calculated_total = 0
	for enemy_type in POOL_SIZES:
		calculated_total += POOL_SIZES[enemy_type]
	
	if calculated_total != EXPECTED_TOTAL:
		push_error(POOL_MISMATCH_FORMAT % [EXPECTED_TOTAL, calculated_total])
	else:
		print(POOL_VERIFY_FORMAT % EXPECTED_TOTAL)

func _initialize_pools():
	for enemy_type in POOL_SIZES:
		var pool_size = POOL_SIZES[enemy_type]
		enemy_pools[enemy_type] = []
		
		print(POOL_CREATE_FORMAT % [pool_size, enemy_type])
		
		for i in pool_size:
			var enemy = _create_enemy(enemy_type)
			if enemy:
				enemy_pools[enemy_type].append(enemy)
				add_child(enemy)
			else:
				push_warning("EnemyPool: Failed to create enemy of type: %s (index: %d)" % [enemy_type, i])

func _create_enemy(enemy_type: String) -> CharacterBody2D:
	# Create enemy programmatically since .tscn files don't exist yet
	# In production, this would load from actual scene files with graceful fallback
	
	var enemy = CharacterBody2D.new()
	enemy.name = "Enemy" + enemy_type.capitalize()
	
	# Add collision
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	
	# Size based on enemy type
	match enemy_type:
		"swarm": shape.size = Vector2(16, 16)
		"ranged": shape.size = Vector2(24, 24)
		"tank": shape.size = Vector2(32, 32)
		"boss": shape.size = Vector2(48, 48)
		_: shape.size = Vector2(20, 20)
	
	collision.shape = shape
	enemy.add_child(collision)
	
	# Add sprite placeholder
	var sprite = Sprite2D.new()
	var texture = ImageTexture.new()
	var image = Image.create(int(shape.size.x), int(shape.size.y), false, Image.FORMAT_RGB8)
	
	# Color coding by type
	match enemy_type:
		"swarm": image.fill(Color.RED)
		"ranged": image.fill(Color.BLUE) 
		"tank": image.fill(Color.GREEN)
		"boss": image.fill(Color.PURPLE)
		_: image.fill(Color.GRAY)
	
	texture.set_image(image)
	sprite.texture = texture
	enemy.add_child(sprite)
	
	# Set collision layers
	enemy.collision_layer = 3  # Enemies
	enemy.collision_mask = 1 | 2 | 4  # Walls, Player, Player Projectiles (NO enemy-enemy collision)
	
	# Add simple AI script
	enemy.set_script(load("res://scripts/BasicEnemy.gd"))
	
	# Add metadata
	enemy.set_meta("enemy_type", enemy_type)
	enemy.set_meta("is_pooled", true)
	enemy.set_meta("active", false)
	enemy.set_meta("max_health", _get_enemy_health(enemy_type))
	enemy.set_meta("current_health", enemy.get_meta("max_health"))
	enemy.set_meta("speed", _get_enemy_speed(enemy_type))
	
	# Initially disable
	enemy.set_physics_process(false)
	enemy.set_process(false)
	enemy.visible = false
	
	return enemy

func _get_enemy_health(enemy_type: String) -> int:
	match enemy_type:
		"swarm": return 20
		"ranged": return 40
		"tank": return 100
		"boss": return 250
		_: return 30

func _get_enemy_speed(enemy_type: String) -> float:
	match enemy_type:
		"swarm": return 120.0
		"ranged": return 80.0
		"tank": return 50.0
		"boss": return 60.0
		_: return 100.0

func get_enemy(enemy_type: String) -> CharacterBody2D:
	if not enemy_type in enemy_pools:
		push_error("EnemyPool: Unknown enemy type requested: %s" % enemy_type)
		# Try to fallback to swarm type
		if "swarm" in enemy_pools and not enemy_pools["swarm"].is_empty():
			push_warning("EnemyPool: Falling back to swarm enemy type")
			enemy_type = "swarm"
		else:
			return null
	
	var pool = enemy_pools[enemy_type]
	
	# Find inactive enemy
	for enemy in pool:
		if not enemy.get_meta("active", false):
			_activate_enemy(enemy)
			return enemy
	
	# Pool exhausted - force reuse oldest enemy
	pool_exhaustion_warnings += 1
	if EventBus:
		EventBus.emit_performance_warning_if(true, "EnemyPool", 
			"pool_exhaustion", pool_exhaustion_warnings)
	
	if pool.size() > 0:
		var enemy = pool[0]  # Get first enemy
		_deactivate_enemy(enemy)
		_activate_enemy(enemy)
		return enemy
	
	push_error("EnemyPool: Empty pool for type: %s" % enemy_type)
	return null

func _activate_enemy(enemy: CharacterBody2D):
	if not is_instance_valid(enemy):
		push_error("EnemyPool: Attempting to activate invalid enemy")
		return
	
	enemy.set_meta("active", true)
	enemy.set_physics_process(true)
	enemy.set_process(true)
	enemy.visible = true
	
	# Reset health
	var max_health = enemy.get_meta("max_health", 50)
	enemy.set_meta("current_health", max_health)
	
	# Reset position and velocity
	enemy.velocity = Vector2.ZERO
	
	active_enemies.append(enemy)
	total_spawned += 1
	peak_active_count = max(peak_active_count, active_enemies.size())
	
	if EventBus:
		EventBus.enemy_spawned.emit(enemy)

func _deactivate_enemy(enemy: CharacterBody2D):
	if not is_instance_valid(enemy):
		return
	
	enemy.set_meta("active", false)
	enemy.set_physics_process(false)
	enemy.set_process(false)
	enemy.visible = false
	
	# Remove from active tracking
	var index = active_enemies.find(enemy)
	if index >= 0:
		active_enemies.remove_at(index)

func return_enemy(enemy: CharacterBody2D):
	if is_instance_valid(enemy) and enemy.get_meta("active", false):
		if EventBus:
			EventBus.entity_died.emit(enemy)
		_deactivate_enemy(enemy)

func _on_enemy_died(enemy: Node2D):
	# Automatically return enemy to pool when it dies
	if enemy is CharacterBody2D and enemy.get_meta("is_pooled", false):
		return_enemy(enemy)

# Performance monitoring interface
func get_active_count() -> int:
	return active_enemies.size()

func get_total_spawned() -> int:
	return total_spawned

func get_peak_active_count() -> int:
	return peak_active_count

func get_pool_stats() -> Dictionary:
	var stats = {}
	for enemy_type in POOL_SIZES:
		var pool = enemy_pools.get(enemy_type, [])
		var active_count = 0
		for enemy in pool:
			if enemy.get_meta("active", false):
				active_count += 1
		
		stats[enemy_type] = {
			"total": pool.size(),
			"active": active_count, 
			"available": pool.size() - active_count
		}
	
	return stats

# Cleanup invalid enemies periodically 
func _process(_delta: float):
	for i in range(active_enemies.size() - 1, -1, -1):
		if not is_instance_valid(active_enemies[i]):
			active_enemies.remove_at(i)
