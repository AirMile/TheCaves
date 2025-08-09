extends Control

# Performance debug panel - Toggle with F3
# Monitors FPS, entities, and collision pairs for 60 FPS target

@onready var fps_label: Label = $VBox/FPS
@onready var enemies_label: Label = $VBox/Enemies  
@onready var projectiles_label: Label = $VBox/Projectiles
@onready var collision_pairs_label: Label = $VBox/CollisionPairs

var update_timer: float = 0.0
const UPDATE_INTERVAL: float = 0.1  # Update 10 times per second for performance

func _ready():
	visible = false
	print("DebugPanel initialized - Press F3 to toggle")
	
	# Connect to EventBus for F3 toggle
	EventBus.debug_panel_toggled.connect(_on_debug_toggle)

func _process(delta: float):
	if not visible:
		return
		
	update_timer += delta
	if update_timer >= UPDATE_INTERVAL:
		update_timer = 0.0
		_update_debug_info()

func _update_debug_info():
	# FPS with color coding
	var fps = Engine.get_frames_per_second()
	fps_label.text = "FPS: %d" % fps
	
	if fps < 45:
		fps_label.modulate = Color.RED
	elif fps < 55:
		fps_label.modulate = Color.YELLOW
	else:
		fps_label.modulate = Color.WHITE
	
	# Enemy count from pool
	var enemy_count = 0
	if EnemyPool:
		enemy_count = EnemyPool.get_active_enemy_count()
	enemies_label.text = "Enemies: %d" % enemy_count
	
	# Color code enemy count (target: 100-150)
	if enemy_count > 150:
		enemies_label.modulate = Color.RED
	elif enemy_count > 100:
		enemies_label.modulate = Color.YELLOW
	else:
		enemies_label.modulate = Color.WHITE
	
	# Projectile count
	var projectile_count = 0
	if ProjectileManager:
		projectile_count = ProjectileManager.get_active_projectile_count()
	projectiles_label.text = "Projectiles: %d" % projectile_count
	
	# Collision pairs (critical for performance)
	var pairs = Performance.get_monitor(Performance.PHYSICS_2D_COLLISION_PAIRS)
	collision_pairs_label.text = "Collision Pairs: %d" % pairs
	
	# Color code collision pairs (target: < 5000)
	if pairs > 5000:
		collision_pairs_label.modulate = Color.RED
	elif pairs > 3000:
		collision_pairs_label.modulate = Color.YELLOW
	else:
		collision_pairs_label.modulate = Color.WHITE

func _on_debug_toggle(should_show: bool):
	visible = should_show
	print("Debug panel %s" % ("shown" if visible else "hidden"))

# Allow manual toggle via input (backup method)
func _input(event: InputEvent):
	if event.is_action_pressed("debug_toggle"):
		visible = !visible
		print("Debug panel toggled: %s" % visible)