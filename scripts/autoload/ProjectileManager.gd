extends Node

# Projectile pooling system - designed for 200-300 active projectiles

const PROJECTILE_POOL_SIZE = 500  # Pool extra for burst scenarios

var projectile_pool: Array[Node2D] = []
var active_projectiles: Array[Node2D] = []

func _ready():
	print("ProjectileManager initializing...")
	_create_projectile_pool()
	print("ProjectileManager initialized with %d projectiles" % PROJECTILE_POOL_SIZE)

func _create_projectile_pool():
	for i in PROJECTILE_POOL_SIZE:
		var projectile = _create_basic_projectile()
		projectile.set_process(false)
		projectile.set_physics_process(false)
		projectile.visible = false
		add_child(projectile)
		projectile_pool.append(projectile)

func _create_basic_projectile() -> Node2D:
	var projectile = CharacterBody2D.new()
	projectile.name = "Projectile"
	
	# Add collision shape
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 4.0
	collision.shape = shape
	projectile.add_child(collision)
	
	# Set collision layers
	projectile.collision_layer = 4  # PlayerProjectiles layer (matches project.godot layer 4)
	projectile.collision_mask = 1 | 3  # Walls + Enemies
	
	projectile.add_to_group("projectiles")
	return projectile

func get_projectile() -> Node2D:
	# Find inactive projectile
	for projectile in projectile_pool:
		if is_instance_valid(projectile) and not projectile.visible:
			_activate_projectile(projectile)
			return projectile
	
	# Force reuse if pool exhausted
	if projectile_pool.size() > 0:
		var projectile = projectile_pool[0]
		return_projectile(projectile)
		_activate_projectile(projectile)
		return projectile
	
	push_error("ProjectileManager: No projectiles available")
	return null

func return_projectile(projectile: Node2D):
	if not is_instance_valid(projectile):
		return
		
	_deactivate_projectile(projectile)
	
	var index = active_projectiles.find(projectile)
	if index != -1:
		active_projectiles.remove_at(index)

func _activate_projectile(projectile: Node2D):
	projectile.set_process(true)
	projectile.set_physics_process(true)
	projectile.visible = true
	
	if active_projectiles.find(projectile) == -1:
		active_projectiles.append(projectile)
	
	EventBus.projectile_fired.emit(projectile)

func _deactivate_projectile(projectile: Node2D):
	projectile.set_process(false)
	projectile.set_physics_process(false)
	projectile.visible = false

func get_active_projectile_count() -> int:
	# Clean up invalid references
	active_projectiles = active_projectiles.filter(func(p): return is_instance_valid(p) and p.visible)
	return active_projectiles.size()