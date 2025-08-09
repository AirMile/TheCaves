extends Node

# Object pooling system for enemies - designed for 100+ enemies at 60 FPS
# Pool 150 enemies (50% over target) to prevent starvation

const POOL_SIZES = {
	"basic": 100,    # Basic swarm enemies
	"ranged": 30,    # Ranged attackers  
	"tank": 15,      # Heavy enemies
	"boss": 5        # Boss enemies
}

var enemy_pools: Dictionary = {}
var active_enemies: Array[Node2D] = []

func _ready():
	print("EnemyPool initializing...")
	_create_pools()
	print("EnemyPool initialized with %d total enemies" % _get_total_pool_size())

func _create_pools():
	for enemy_type in POOL_SIZES:
		enemy_pools[enemy_type] = []
		var scene_path = "res://scenes/enemies/Enemy%s.tscn" % enemy_type.capitalize()
		
		# Check if scene exists, create basic scene if not
		if not ResourceLoader.exists(scene_path):
			print("Warning: %s not found, using BasicEnemy instead" % scene_path)
			_create_basic_enemy_pool(enemy_type)
		else:
			_create_typed_enemy_pool(enemy_type, scene_path)

func _create_basic_enemy_pool(enemy_type: String):
	var basic_enemy_scene = preload("res://scenes/BasicEnemy.tscn") if ResourceLoader.exists("res://scenes/BasicEnemy.tscn") else null
	
	for i in POOL_SIZES[enemy_type]:
		var enemy: CharacterBody2D
		if basic_enemy_scene:
			enemy = basic_enemy_scene.instantiate()
		else:
			# Create basic enemy programmatically if no scene exists
			enemy = CharacterBody2D.new()
			enemy.name = "BasicEnemy_%d" % i
			
			# Add collision shape
			var collision = CollisionShape2D.new()
			var shape = CircleShape2D.new()
			shape.radius = 16.0
			collision.shape = shape
			enemy.add_child(collision)
			
			# Set script if it exists
			if ResourceLoader.exists("res://scripts/BasicEnemy.gd"):
				enemy.set_script(load("res://scripts/BasicEnemy.gd"))
		
		_setup_pooled_enemy(enemy, enemy_type)
		enemy_pools[enemy_type].append(enemy)

func _create_typed_enemy_pool(enemy_type: String, scene_path: String):
	var scene = load(scene_path)
	for i in POOL_SIZES[enemy_type]:
		var enemy = scene.instantiate()
		_setup_pooled_enemy(enemy, enemy_type)
		enemy_pools[enemy_type].append(enemy)

func _setup_pooled_enemy(enemy: Node2D, enemy_type: String):
	# Configure for pooling
	enemy.set_process(false)
	enemy.set_physics_process(false)
	enemy.visible = false
	
	# Set collision layers for performance (no inter-enemy collision)
	if enemy is CharacterBody2D:
		enemy.collision_layer = 4  # Enemy layer
		enemy.collision_mask = 1 | 2  # Walls + Player only
	
	# Add to scene tree but keep inactive
	add_child(enemy)
	
	# Add to groups for identification
	enemy.add_to_group("enemies")
	enemy.add_to_group("pooled_" + enemy_type)

func get_enemy(enemy_type: String) -> Node2D:
	var pool = enemy_pools.get(enemy_type, [])
	
	# FIXED: Proper bounds checking (Issue #17)
	if pool.size() == 0:
		push_error("EnemyPool: No enemies available in %s pool" % enemy_type)
		return null
	
	# Find inactive enemy
	for enemy in pool:
		if is_instance_valid(enemy) and not _is_enemy_active(enemy):
			_activate_enemy(enemy)
			return enemy
	
	# If all enemies are active, force reuse first enemy (prevents crash)
	print("Warning: EnemyPool exhausted for %s, forcing reuse" % enemy_type)
	var enemy = pool[0]
	if is_instance_valid(enemy):
		_deactivate_enemy(enemy)
		_activate_enemy(enemy)
		return enemy
	
	push_error("EnemyPool: Invalid enemy in pool")
	return null

func return_enemy(enemy: Node2D):
	if not is_instance_valid(enemy):
		return
		
	_deactivate_enemy(enemy)
	
	# Remove from active list
	var index = active_enemies.find(enemy)
	if index != -1:
		active_enemies.remove_at(index)

func _activate_enemy(enemy: Node2D):
	if not is_instance_valid(enemy):
		return
		
	enemy.set_process(true)
	enemy.set_physics_process(true) 
	enemy.visible = true
	
	# Reset position to spawn location (will be set by spawner)
	enemy.global_position = Vector2.ZERO
	
	# Add to active tracking
	if active_enemies.find(enemy) == -1:
		active_enemies.append(enemy)
	
	# Emit spawn event
	EventBus.enemy_spawned.emit(enemy)

func _deactivate_enemy(enemy: Node2D):
	if not is_instance_valid(enemy):
		return
		
	enemy.set_process(false)
	enemy.set_physics_process(false)
	enemy.visible = false
	
	# Reset any enemy state if it has a reset method
	if enemy.has_method("reset_for_pool"):
		enemy.reset_for_pool()

func _is_enemy_active(enemy: Node2D) -> bool:
	return enemy.visible and enemy.is_processing()

func get_active_enemy_count() -> int:
	# Clean up invalid references
	active_enemies = active_enemies.filter(func(enemy): return is_instance_valid(enemy) and _is_enemy_active(enemy))
	return active_enemies.size()

func get_pool_status() -> Dictionary:
	var status = {}
	for enemy_type in enemy_pools:
		var pool = enemy_pools[enemy_type]
		var active_count = 0
		var valid_count = 0
		
		for enemy in pool:
			if is_instance_valid(enemy):
				valid_count += 1
				if _is_enemy_active(enemy):
					active_count += 1
		
		status[enemy_type] = {
			"total": pool.size(),
			"valid": valid_count,
			"active": active_count,
			"available": valid_count - active_count
		}
	
	return status

func _get_total_pool_size() -> int:
	var total = 0
	for size in POOL_SIZES.values():
		total += size
	return total

# Debug function for performance monitoring
func print_pool_status():
	print("=== Enemy Pool Status ===")
	var status = get_pool_status()
	for enemy_type in status:
		var data = status[enemy_type]
		print("%s: %d/%d active (%d available)" % [
			enemy_type.capitalize(),
			data.active,
			data.total, 
			data.available
		])
	print("Total active enemies: %d" % get_active_enemy_count())