extends CharacterBody2D
class_name BasicEnemy

# Basic enemy with LOD system for performance with 100+ enemies

enum DetailLevel { HIGH, MEDIUM, LOW, MINIMAL }

const SPEED: float = 100.0
const HEALTH: int = 50
const DAMAGE: int = 10

var target: Node2D = null
var current_health: int = HEALTH
var current_lod: DetailLevel = DetailLevel.HIGH
var lod_update_timer: float = 0.0
const LOD_UPDATE_INTERVAL: float = 0.1  # Update LOD 10 times per second

# Performance optimization: cache player reference
@onready var player_ref: Node2D = null

func _ready():
	add_to_group("enemies")
	current_health = HEALTH
	
	# Setup collision layers (no inter-enemy collision for performance)
	collision_layer = 4  # Enemy layer  
	collision_mask = 1 | 2  # Walls + Player only
	
	print("BasicEnemy initialized")

func _physics_process(delta: float):
	# Update LOD less frequently for performance
	lod_update_timer += delta
	if lod_update_timer >= LOD_UPDATE_INTERVAL:
		lod_update_timer = 0.0
		_update_lod()
	
	# Behavior based on current LOD level
	match current_lod:
		DetailLevel.HIGH:      # 0-300px - Full AI
			_full_ai_update(delta)
		DetailLevel.MEDIUM:    # 300-600px - Simple movement
			_simple_movement(delta)
		DetailLevel.LOW:       # 600-900px - Basic movement only
			_basic_movement(delta)
		DetailLevel.MINIMAL:   # 900px+ - Position only, minimal processing
			pass

func _update_lod():
	# Cache player reference if needed
	if not is_instance_valid(player_ref):
		player_ref = get_tree().get_first_node_in_group("player")
		if not player_ref:
			return
	
	var distance_sq = global_position.distance_squared_to(player_ref.global_position)
	
	# Update LOD based on distance (squared for performance)
	if distance_sq < 90000:      # 300px
		current_lod = DetailLevel.HIGH
	elif distance_sq < 360000:   # 600px
		current_lod = DetailLevel.MEDIUM  
	elif distance_sq < 810000:   # 900px
		current_lod = DetailLevel.LOW
	else:
		current_lod = DetailLevel.MINIMAL

func _full_ai_update(delta: float):
	if not is_instance_valid(player_ref):
		return
		
	# Full AI behavior - pathfinding, attacks, abilities
	var direction = global_position.direction_to(player_ref.global_position)
	velocity = direction * SPEED
	move_and_slide()
	
	# Check for player collision/damage
	_check_player_collision()

func _simple_movement(delta: float):
	if not is_instance_valid(player_ref):
		return
		
	# Simple movement toward player
	var direction = global_position.direction_to(player_ref.global_position)
	velocity = direction * SPEED * 0.7  # Slower at medium distance
	move_and_slide()

func _basic_movement(delta: float):
	if not is_instance_valid(player_ref):
		return
		
	# Very basic movement, reduced frequency
	var direction = global_position.direction_to(player_ref.global_position)
	velocity = direction * SPEED * 0.5  # Even slower at long distance
	move_and_slide()

func _check_player_collision():
	# Only check collision at HIGH detail level
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider and collider.is_in_group("player"):
			_damage_player(collider)
			break

func _damage_player(player: Node2D):
	if player.has_method("take_damage"):
		player.take_damage(DAMAGE)
		print("Enemy damaged player for %d" % DAMAGE)

func take_damage(amount: int):
	current_health -= amount
	print("Enemy took %d damage, health: %d" % [amount, current_health])
	
	if current_health <= 0:
		_die()

func _die():
	print("Enemy died")
	EventBus.enemy_died.emit(self)
	
	# Return to pool instead of queue_free
	if EnemyPool:
		EnemyPool.return_enemy(self)
	else:
		queue_free()

# Called by EnemyPool when returning to pool
func reset_for_pool():
	current_health = HEALTH
	velocity = Vector2.ZERO
	current_lod = DetailLevel.HIGH
	target = null
	player_ref = null

# Debug function
func get_debug_info() -> Dictionary:
	return {
		"position": global_position,
		"health": current_health,
		"lod": DetailLevel.keys()[current_lod],
		"target_valid": is_instance_valid(target)
	}