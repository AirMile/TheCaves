extends Node
## High-performance projectile pooling system
## Manages 500 projectile instances with zero runtime allocation

# Pool configuration - total 500 projectiles
const POOL_SIZE: int = 500
const PROJECTILE_TYPES: Array[String] = ["bullet", "magic", "explosive"]

# Fixed pool distribution to avoid integer division issues
const POOL_DISTRIBUTION: Dictionary = {
	"bullet": 250,     # 50% - most common
	"magic": 150,      # 30% - medium usage  
	"explosive": 100   # 20% - least common but impactful
}

# Pool storage
var projectile_pools: Dictionary = {}
var active_projectiles: Array[Node2D] = []

# Performance monitoring
var peak_active_count: int = 0
var pool_exhaustion_count: int = 0

func _ready():
	_initialize_pools()
	_verify_pool_distribution()
	
	# Connect to performance monitoring
	if EventBus:
		EventBus.connect("performance_warning", _on_performance_warning)

func _initialize_pools():
	for projectile_type in PROJECTILE_TYPES:
		var pool_size = POOL_DISTRIBUTION.get(projectile_type, 0)
		projectile_pools[projectile_type] = []
		
		print("ProjectileManager: Initializing %d %s projectiles" % [pool_size, projectile_type])
		
		# Create pool instances
		for i in pool_size:
			var projectile = _create_projectile(projectile_type)
			if projectile:
				projectile_pools[projectile_type].append(projectile)
				add_child(projectile)
			else:
				push_warning("ProjectileManager: Failed to create projectile of type: " + projectile_type)

func _verify_pool_distribution():
	var total_allocated = 0
	for type in PROJECTILE_TYPES:
		total_allocated += POOL_DISTRIBUTION.get(type, 0)
	
	if total_allocated != POOL_SIZE:
		push_error("ProjectileManager: Pool distribution mismatch. Expected: %d, Got: %d" % [POOL_SIZE, total_allocated])

func _create_projectile(type: String) -> Node2D:
	# Create basic projectile scene programmatically since scenes don't exist yet
	# In production, this would load actual .tscn files
	var projectile = RigidBody2D.new()
	projectile.name = "Projectile" + type.capitalize()
	
	# Add collision shape
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 4.0
	collision.shape = shape
	projectile.add_child(collision)
	
	# Add sprite (placeholder)
	var sprite = Sprite2D.new()
	var texture = ImageTexture.new()
	var image = Image.create(8, 8, false, Image.FORMAT_RGB8)
	image.fill(Color.WHITE)
	texture.set_image(image)
	sprite.texture = texture
	projectile.add_child(sprite)
	
	# Set up physics
	projectile.gravity_scale = 0.0
	projectile.collision_layer = 4  # Player projectiles
	projectile.collision_mask = 1 | 3  # Walls and enemies
	
	# Add custom properties
	projectile.set_meta("projectile_type", type)
	projectile.set_meta("is_pooled", true)
	projectile.set_meta("active", false)
	
	# Initially disable
	projectile.set_physics_process(false)
	projectile.set_process(false)
	projectile.visible = false
	
	return projectile

func get_projectile(type: String) -> Node2D:
	if not type in projectile_pools:
		push_error("ProjectileManager: Unknown projectile type: " + type)
		return null
	
	var pool = projectile_pools[type]
	
	# Find inactive projectile
	for projectile in pool:
		if not projectile.get_meta("active", false):
			_activate_projectile(projectile)
			return projectile
	
	# Pool exhausted - reuse oldest active projectile
	pool_exhaustion_count += 1
	if pool.size() > 0:
		var projectile = pool[0]
		_deactivate_projectile(projectile)
		_activate_projectile(projectile)
		
		# Emit performance warning
		if EventBus:
			EventBus.emit_performance_warning_if(true, "ProjectileManager", 
				"pool_exhaustion", pool_exhaustion_count)
		
		return projectile
	
	push_error("ProjectileManager: Empty pool for type: " + type)
	return null

func _activate_projectile(projectile: Node2D):
	if not is_instance_valid(projectile):
		push_error("ProjectileManager: Attempting to activate invalid projectile")
		return
		
	projectile.set_meta("active", true)
	projectile.set_physics_process(true)
	projectile.set_process(true)  
	projectile.visible = true
	
	# Reset physics state
	projectile.linear_velocity = Vector2.ZERO
	projectile.angular_velocity = 0.0
	
	active_projectiles.append(projectile)
	peak_active_count = max(peak_active_count, active_projectiles.size())

func _deactivate_projectile(projectile: Node2D):
	if not is_instance_valid(projectile):
		return
		
	projectile.set_meta("active", false)
	projectile.set_physics_process(false)
	projectile.set_process(false)
	projectile.visible = false
	
	# Remove from active list
	var index = active_projectiles.find(projectile)
	if index >= 0:
		active_projectiles.remove_at(index)

func return_projectile(projectile: Node2D):
	if is_instance_valid(projectile) and projectile.get_meta("active", false):
		_deactivate_projectile(projectile)

# Performance monitoring
func get_active_count() -> int:
	return active_projectiles.size()

func get_peak_active_count() -> int:
	return peak_active_count

func get_pool_exhaustion_count() -> int:
	return pool_exhaustion_count

func _on_performance_warning(system: String, metric: String, value: float):
	if system == "ProjectileManager":
		print("ProjectileManager Warning: %s = %f" % [metric, value])

# Cleanup invalid projectiles periodically
func _process(_delta: float):
	# Remove invalid projectiles from active list
	for i in range(active_projectiles.size() - 1, -1, -1):
		if not is_instance_valid(active_projectiles[i]):
			active_projectiles.remove_at(i)