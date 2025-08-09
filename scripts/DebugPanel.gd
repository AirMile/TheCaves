extends Control
class_name DebugPanel
## F3 Performance monitoring panel for debugging and optimization
## Shows FPS, entity counts, collision pairs and other performance metrics

@onready var fps_label: Label = $VBox/FPS
@onready var enemies_label: Label = $VBox/Enemies  
@onready var projectiles_label: Label = $VBox/Projectiles
@onready var collision_pairs_label: Label = $VBox/CollisionPairs
@onready var memory_label: Label = $VBox/Memory
@onready var frame_time_label: Label = $VBox/FrameTime

# Cached format strings for performance
const FPS_FORMAT: String = "FPS: %d (Target: 60)"
const ENEMIES_FORMAT: String = "Enemies: %d/%d (Peak: %d)"  
const PROJECTILES_FORMAT: String = "Projectiles: %d/500"
const COLLISION_PAIRS_FORMAT: String = "Collision Pairs: %d (Limit: 5000)"
const MEMORY_FORMAT: String = "Memory: %.1fMB"
const FRAME_TIME_FORMAT: String = "Frame Time: %.2fms (Budget: 16.67ms)"

# Performance thresholds
const FPS_WARNING_THRESHOLD: int = 55
const COLLISION_PAIRS_WARNING: int = 5000
const FRAME_TIME_WARNING: float = 18.0  # 18ms = approaching budget limit

func _ready():
	visible = false
	
	# Create UI if nodes don't exist
	_ensure_ui_exists()

func _ensure_ui_exists():
	# Create VBox container if it doesn't exist
	if not has_node("VBox"):
		var vbox = VBoxContainer.new()
		vbox.name = "VBox"
		add_child(vbox)
		
		# Create labels
		fps_label = _create_debug_label("FPS")
		enemies_label = _create_debug_label("Enemies")
		projectiles_label = _create_debug_label("Projectiles") 
		collision_pairs_label = _create_debug_label("CollisionPairs")
		memory_label = _create_debug_label("Memory")
		frame_time_label = _create_debug_label("FrameTime")
		
		vbox.add_child(fps_label)
		vbox.add_child(enemies_label)
		vbox.add_child(projectiles_label)
		vbox.add_child(collision_pairs_label)
		vbox.add_child(memory_label)
		vbox.add_child(frame_time_label)

func _create_debug_label(label_name: String) -> Label:
	var label = Label.new()
	label.name = label_name
	label.add_theme_color_override("font_color", Color.WHITE)
	return label

func _process(_delta: float):
	if Input.is_action_just_pressed("debug_toggle"):  # F3
		visible = !visible
	
	if visible:
		_update_debug_info()

func _update_debug_info():
	# FPS monitoring
	var fps = Engine.get_frames_per_second()
	fps_label.text = FPS_FORMAT % fps
	
	if fps < FPS_WARNING_THRESHOLD:
		fps_label.add_theme_color_override("font_color", Color.RED)
	else:
		fps_label.add_theme_color_override("font_color", Color.WHITE)
	
	# Enemy count monitoring
	var enemy_count = get_tree().get_nodes_in_group("enemies").size()
	var peak_count = EnemyPool.get_peak_active_count() if EnemyPool else 0
	enemies_label.text = ENEMIES_FORMAT % [enemy_count, 150, peak_count]
	
	# Projectile monitoring
	var projectile_count = get_tree().get_nodes_in_group("projectiles").size()
	projectiles_label.text = PROJECTILES_FORMAT % projectile_count
	
	# Collision pairs monitoring
	var collision_pairs = Performance.get_monitor(Performance.PHYSICS_2D_COLLISION_PAIRS)
	collision_pairs_label.text = COLLISION_PAIRS_FORMAT % collision_pairs
	
	if collision_pairs > COLLISION_PAIRS_WARNING:
		collision_pairs_label.add_theme_color_override("font_color", Color.RED)
	else:
		collision_pairs_label.add_theme_color_override("font_color", Color.WHITE)
	
	# Memory monitoring  
	var memory_mb = Performance.get_monitor(Performance.MEMORY_STATIC) / 1024.0 / 1024.0
	memory_label.text = MEMORY_FORMAT % memory_mb
	
	# Frame time monitoring
	var frame_time = Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0  # Convert to ms
	frame_time_label.text = FRAME_TIME_FORMAT % frame_time
	
	if frame_time > FRAME_TIME_WARNING:
		frame_time_label.add_theme_color_override("font_color", Color.ORANGE)
	elif frame_time > 16.67:  # Over budget
		frame_time_label.add_theme_color_override("font_color", Color.RED) 
	else:
		frame_time_label.add_theme_color_override("font_color", Color.WHITE)

# Public interface for external monitoring
func get_performance_summary() -> Dictionary:
	return {
		"fps": Engine.get_frames_per_second(),
		"enemies": get_tree().get_nodes_in_group("enemies").size(),
		"projectiles": get_tree().get_nodes_in_group("projectiles").size(),
		"collision_pairs": Performance.get_monitor(Performance.PHYSICS_2D_COLLISION_PAIRS),
		"memory_mb": Performance.get_monitor(Performance.MEMORY_STATIC) / 1024.0 / 1024.0,
		"frame_time_ms": Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	}

func is_performance_critical() -> bool:
	var fps = Engine.get_frames_per_second()
	var collision_pairs = Performance.get_monitor(Performance.PHYSICS_2D_COLLISION_PAIRS)
	var frame_time = Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	
	return fps < FPS_WARNING_THRESHOLD or collision_pairs > COLLISION_PAIRS_WARNING or frame_time > FRAME_TIME_WARNING