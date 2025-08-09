extends Node

const POOL_SIZE: int = 500

const PROJECTILE_TYPES = {
	"bullet": "res://scenes/projectiles/Bullet.tscn",
	"magic_bolt": "res://scenes/projectiles/MagicBolt.tscn", 
	"arrow": "res://scenes/projectiles/Arrow.tscn",
	"enemy_projectile": "res://scenes/projectiles/EnemyProjectile.tscn"
}

var projectile_pools: Dictionary = {}
var projectile_scenes: Dictionary = {}
var active_projectiles: Array[Node2D] = []

@onready var pool_container: Node2D

func _ready():
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	
	pool_container = Node2D.new()
	pool_container.name = "ProjectilePoolContainer"
	add_child(pool_container)
	
	_initialize_pools()
	
	EventBus.weapon_fired.connect(_on_weapon_fired)
	EventBus.projectile_hit.connect(_on_projectile_hit)
	
	if OS.is_debug_build():
		print("[ProjectileManager] Initialized - Pool size: %d per type" % POOL_SIZE)

func _initialize_pools():
	for projectile_type in PROJECTILE_TYPES:
		projectile_pools[projectile_type] = []
		
		var scene_path = PROJECTILE_TYPES[projectile_type]
		
		if ResourceLoader.exists(scene_path):
			projectile_scenes[projectile_type] = load(scene_path)
		else:
			if OS.is_debug_build():
				print("[ProjectileManager] Warning: Scene not found: %s" % scene_path)
			continue
		
		var pool_size_per_type = POOL_SIZE / PROJECTILE_TYPES.size()
		for i in pool_size_per_type:
			var projectile = projectile_scenes[projectile_type].instantiate()
			projectile.set_process(false)
			projectile.set_physics_process(false)
			projectile.visible = false
			projectile.set_collision_layer_value(4, false)  # Disable player projectile layer
			projectile.set_collision_layer_value(5, false)  # Disable enemy projectile layer
			projectile.set_collision_mask_value(1, false)   # Disable wall collision
			projectile.set_collision_mask_value(2, false)   # Disable player collision
			projectile.set_collision_mask_value(3, false)   # Disable enemy collision
			
			if projectile.has_method("deactivate"):
				projectile.deactivate()
			
			pool_container.add_child(projectile)
			projectile_pools[projectile_type].append(projectile)

func get_projectile(type: String) -> Node2D:
	if not projectile_pools.has(type):
		if OS.is_debug_build():
			print("[ProjectileManager] Warning: Unknown projectile type: %s" % type)
		return null
	
	var pool = projectile_pools[type]
	for projectile in pool:
		if projectile.has_method("is_active") and not projectile.is_active():
			return projectile
		elif not projectile.has_method("is_active") and not projectile.visible:
			return projectile
	
	if OS.is_debug_build():
		print("[ProjectileManager] Warning: Pool exhausted for type: %s, reusing oldest projectile" % type)
	
	return pool[0]

func fire_projectile(type: String, position: Vector2, direction: Vector2, speed: float, damage: int, is_player_projectile: bool = true) -> Node2D:
	var projectile = get_projectile(type)
	if not projectile:
		return null
	
	_activate_projectile(projectile, position, direction, speed, damage, is_player_projectile)
	return projectile

func _activate_projectile(projectile: Node2D, position: Vector2, direction: Vector2, speed: float, damage: int, is_player_projectile: bool):
	projectile.global_position = position
	projectile.visible = true
	projectile.set_process(true)
	projectile.set_physics_process(true)
	
	if is_player_projectile:
		projectile.set_collision_layer_value(4, true)   # Player projectile layer
		projectile.set_collision_mask_value(1, true)    # Walls
		projectile.set_collision_mask_value(3, true)    # Enemies
	else:
		projectile.set_collision_layer_value(5, true)   # Enemy projectile layer
		projectile.set_collision_mask_value(1, true)    # Walls
		projectile.set_collision_mask_value(2, true)    # Player
	
	if projectile.has_method("initialize"):
		projectile.initialize(direction, speed, damage)
	elif projectile.has_method("activate"):
		projectile.activate()
	
	if projectile.has_method("set_direction"):
		projectile.set_direction(direction)
	
	if projectile.has_method("set_speed"):
		projectile.set_speed(speed)
	
	if projectile.has_method("set_damage"):
		projectile.set_damage(damage)
	
	if not active_projectiles.has(projectile):
		active_projectiles.append(projectile)

func _on_weapon_fired(weapon_name: String, position: Vector2, direction: Vector2):
	pass

func _on_projectile_hit(target: Node2D, damage: int):
	pass

func deactivate_projectile(projectile: Node2D):
	if projectile == null:
		return
	
	projectile.visible = false
	projectile.set_process(false)
	projectile.set_physics_process(false)
	
	projectile.set_collision_layer_value(4, false)
	projectile.set_collision_layer_value(5, false)
	projectile.set_collision_mask_value(1, false)
	projectile.set_collision_mask_value(2, false)
	projectile.set_collision_mask_value(3, false)
	
	if projectile.has_method("deactivate"):
		projectile.deactivate()
	
	if active_projectiles.has(projectile):
		active_projectiles.erase(projectile)

func get_active_projectile_count() -> int:
	return active_projectiles.size()

func get_active_projectiles() -> Array[Node2D]:
	return active_projectiles.duplicate()

func deactivate_all_projectiles():
	for projectile in active_projectiles.duplicate():
		deactivate_projectile(projectile)
	active_projectiles.clear()

func cleanup_distant_projectiles(player_position: Vector2, max_distance: float = 2000.0):
	var max_distance_sq = max_distance * max_distance
	
	for projectile in active_projectiles.duplicate():
		var distance_sq = projectile.global_position.distance_squared_to(player_position)
		if distance_sq > max_distance_sq:
			deactivate_projectile(projectile)

func get_pool_stats() -> Dictionary:
	var stats = {}
	for projectile_type in PROJECTILE_TYPES:
		var pool = projectile_pools.get(projectile_type, [])
		var active_count = 0
		for projectile in pool:
			if projectile.has_method("is_active") and projectile.is_active():
				active_count += 1
			elif not projectile.has_method("is_active") and projectile.visible:
				active_count += 1
		
		stats[projectile_type] = {
			"total": pool.size(),
			"active": active_count,
			"available": pool.size() - active_count
		}
	
	return stats