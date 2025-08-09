extends Node

const POOL_SIZES = {
	"swarm": 80,    # Small, numerous
	"ranged": 40,   # Medium count  
	"tank": 20,     # Few but heavy
	"boss": 2       # Rare spawns
}

var enemy_pools: Dictionary = {}
var enemy_scenes: Dictionary = {}
var active_enemies: Array[Node2D] = []

@onready var pool_container: Node2D

func _ready():
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	
	pool_container = Node2D.new()
	pool_container.name = "EnemyPoolContainer"
	add_child(pool_container)
	
	_initialize_pools()
	
	EventBus.enemy_died.connect(_on_enemy_died)
	
	if OS.is_debug_build():
		print("[EnemyPool] Initialized - Pool sizes: %s" % str(POOL_SIZES))

func _initialize_pools():
	for enemy_type in POOL_SIZES:
		enemy_pools[enemy_type] = []
		
		var scene_path = "res://scenes/enemies/Enemy%s.tscn" % enemy_type.capitalize()
		
		if ResourceLoader.exists(scene_path):
			enemy_scenes[enemy_type] = load(scene_path)
		else:
			if OS.is_debug_build():
				print("[EnemyPool] Warning: Scene not found: %s" % scene_path)
			continue
		
		for i in POOL_SIZES[enemy_type]:
			var enemy = enemy_scenes[enemy_type].instantiate()
			enemy.set_process(false)
			enemy.set_physics_process(false)
			enemy.visible = false
			enemy.set_collision_layer_value(3, false)  # Disable enemy collision layer
			enemy.set_collision_mask_value(1, false)   # Disable all collision masks
			enemy.set_collision_mask_value(2, false)
			enemy.set_collision_mask_value(4, false)
			
			if enemy.has_method("deactivate"):
				enemy.deactivate()
			
			pool_container.add_child(enemy)
			enemy_pools[enemy_type].append(enemy)

func get_enemy(type: String) -> Node2D:
	if not enemy_pools.has(type):
		if OS.is_debug_build():
			print("[EnemyPool] Warning: Unknown enemy type: %s" % type)
		return null
	
	var pool = enemy_pools[type]
	for enemy in pool:
		if enemy.has_method("is_active") and not enemy.is_active():
			_activate_enemy(enemy, type)
			return enemy
		elif not enemy.has_method("is_active") and not enemy.visible:
			_activate_enemy(enemy, type)
			return enemy
	
	if OS.is_debug_build():
		print("[EnemyPool] Warning: Pool exhausted for type: %s, reusing oldest enemy" % type)
	
	var reused_enemy = pool[0]
	_activate_enemy(reused_enemy, type)
	return reused_enemy

func _activate_enemy(enemy: Node2D, type: String):
	enemy.visible = true
	enemy.set_process(true)
	enemy.set_physics_process(true)
	
	enemy.set_collision_layer_value(3, true)   # Enable enemy layer
	enemy.set_collision_mask_value(1, true)    # Walls
	enemy.set_collision_mask_value(2, true)    # Player
	enemy.set_collision_mask_value(4, true)    # Player Projectiles
	
	if enemy.has_method("activate"):
		enemy.activate()
	
	if not active_enemies.has(enemy):
		active_enemies.append(enemy)
	
	EventBus.enemy_spawned.emit(enemy)

func _on_enemy_died(enemy_position: Vector2, enemy_type: String):
	pass

func deactivate_enemy(enemy: Node2D):
	if enemy == null:
		return
	
	enemy.visible = false
	enemy.set_process(false)
	enemy.set_physics_process(false)
	
	enemy.set_collision_layer_value(3, false)
	enemy.set_collision_mask_value(1, false)
	enemy.set_collision_mask_value(2, false)
	enemy.set_collision_mask_value(4, false)
	
	if enemy.has_method("deactivate"):
		enemy.deactivate()
	
	if active_enemies.has(enemy):
		active_enemies.erase(enemy)

func get_active_enemy_count() -> int:
	return active_enemies.size()

func get_active_enemies() -> Array[Node2D]:
	return active_enemies.duplicate()

func deactivate_all_enemies():
	for enemy in active_enemies.duplicate():
		deactivate_enemy(enemy)
	active_enemies.clear()

func get_pool_stats() -> Dictionary:
	var stats = {}
	for enemy_type in POOL_SIZES:
		var pool = enemy_pools.get(enemy_type, [])
		var active_count = 0
		for enemy in pool:
			if enemy.has_method("is_active") and enemy.is_active():
				active_count += 1
			elif not enemy.has_method("is_active") and enemy.visible:
				active_count += 1
		
		stats[enemy_type] = {
			"total": pool.size(),
			"active": active_count,
			"available": pool.size() - active_count
		}
	
	return stats