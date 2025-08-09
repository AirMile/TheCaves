# 🔍 Complete Godot Debugging Guide voor TheCaves Roguelite

Een complete handleiding voor debugging in Godot 4.3, specifiek voor roguelite games met 100+ enemies en neon effects.

## 📊 TL;DR - Belangrijkste Bevindingen

### 🚨 #1 Performance Killer: Collision Pairs
**Collision pairs zijn de grootste bottleneck** - houd dit onder 5,000 voor goede performance, nooit boven 10,000.

### 🎯 Performance Targets voor TheCaves
- **60 FPS** met 150+ actieve enemies  
- **Frame time** onder 16.67ms consistent
- **Collision pairs** < 5,000 (kritiek < 10,000)
- **Memory** < 200MB normaal (< 500MB maximum)
- **Draw calls** < 1,000 (kritiek < 2,000)

---

## 🛠️ Core Debugging Arsenal

### 1. Godot Built-in Tools

#### Enhanced Performance Monitoring
```gdscript
# PerformanceMonitor.gd - Autoload singleton
extends Node

# Built-in monitors
var critical_monitors = {
    "fps": Performance.TIME_FPS,
    "collision_pairs": Performance.PHYSICS_2D_COLLISION_PAIRS,
    "frame_time": Performance.TIME_PROCESS,
    "physics_time": Performance.TIME_PHYSICS_PROCESS,
    "memory_static": Performance.MEMORY_STATIC,
    "memory_peak": Performance.MEMORY_STATIC_MAX,
    "draw_calls": Performance.RENDER_2D_DRAW_CALLS_IN_FRAME,
    "texture_mem": Performance.RENDER_TEXTURE_MEM_USED,
    "vertex_mem": Performance.RENDER_BUFFER_MEM_USED,
    "physics_objects": Performance.PHYSICS_2D_ACTIVE_OBJECTS
}

# Custom monitors voor TheCaves
func _ready():
    # Register custom monitors
    Performance.add_custom_monitor("thecaves/enemies", get_enemy_count)
    Performance.add_custom_monitor("thecaves/projectiles", get_projectile_count)
    Performance.add_custom_monitor("thecaves/neon_effects", get_active_shader_count)
    Performance.add_custom_monitor("thecaves/pool_usage", get_pool_usage_percent)
    Performance.add_custom_monitor("thecaves/lod_distribution", get_lod_distribution)
    
    # Start monitoring thread
    _start_monitoring()

func _start_monitoring():
    var monitoring_thread = Thread.new()
    monitoring_thread.start(_monitor_thread)

func _monitor_thread():
    while true:
        _check_performance_thresholds()
        OS.delay_msec(100)  # Check every 100ms

func _check_performance_thresholds():
    var fps = Performance.get_monitor(Performance.TIME_FPS)
    var collision_pairs = Performance.get_monitor(Performance.PHYSICS_2D_COLLISION_PAIRS)
    var memory_mb = Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0
    
    # Alert system with detailed diagnostics
    if collision_pairs > 8000:
        _analyze_collision_hotspots()
    if fps < 50:
        _profile_performance_bottleneck()
    if memory_mb > 300:
        _detect_memory_leaks()

func _analyze_collision_hotspots():
    var enemies = get_tree().get_nodes_in_group("enemies")
    var clusters = {}
    
    # Find collision clusters
    for enemy in enemies:
        var grid_pos = (enemy.global_position / 100).floor()
        var key = "%d,%d" % [grid_pos.x, grid_pos.y]
        if not clusters.has(key):
            clusters[key] = 0
        clusters[key] += 1
    
    # Report hotspots
    for pos in clusters:
        if clusters[pos] > 20:
            Logger.log_warning("Collision hotspot at %s: %d enemies" % [pos, clusters[pos]])

func get_enemy_count() -> int:
    return get_tree().get_nodes_in_group("enemies").size()

func get_projectile_count() -> int:
    return get_tree().get_nodes_in_group("projectiles").size()

func get_active_shader_count() -> int:
    return NeonEffectManager.get_active_shader_count()

func get_pool_usage_percent() -> float:
    return EnemyPool.get_usage_percentage()

func get_lod_distribution() -> float:
    # Return percentage of enemies in LOW/MINIMAL LOD
    var total = 0
    var low_detail = 0
    for enemy in get_tree().get_nodes_in_group("enemies"):
        total += 1
        if enemy.current_lod >= Enemy.LOD.LOW:
            low_detail += 1
    return (low_detail / float(max(total, 1))) * 100.0
```

#### Command-Line Debug Flags
```bash
# Launch met collision visualization
godot --debug-collisions

# Launch met profiler auto-start
godot --debug-settings

# Remote debugging
godot --remote-debug tcp://127.0.0.1:6007

# Verbose physics output
godot --verbose --physics-2d-verbose
```

### 2. Advanced Logging System

```gdscript
# Logger.gd - Enhanced Autoload singleton
extends Node

enum LogLevel { DEBUG, INFO, WARNING, ERROR, PERFORMANCE, COLLISION }
enum LogTarget { CONSOLE, FILE, NETWORK, ALL }

var log_level: LogLevel = LogLevel.INFO
var log_targets: Array[LogTarget] = [LogTarget.CONSOLE, LogTarget.FILE]
var log_file: FileAccess = null
var performance_log: FileAccess = null
var collision_log: FileAccess = null
var log_buffer: PackedStringArray = []
var buffer_size: int = 100

signal log_message(level: LogLevel, message: String)

func _ready():
    if OS.is_debug_build():
        _setup_log_files()
        _setup_crash_handler()

func _setup_log_files():
    var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
    var log_dir = "user://logs/"
    DirAccess.make_dir_recursive_absolute(log_dir)
    
    # Main log
    log_file = FileAccess.open("%sdebug_%s.log" % [log_dir, timestamp], FileAccess.WRITE)
    
    # Performance specific log
    performance_log = FileAccess.open("%sperformance_%s.csv" % [log_dir, timestamp], FileAccess.WRITE)
    performance_log.store_line("timestamp,fps,collision_pairs,memory_mb,enemies,projectiles,frame_time_ms")
    
    # Collision analysis log
    collision_log = FileAccess.open("%scollisions_%s.log" % [log_dir, timestamp], FileAccess.WRITE)

func _setup_crash_handler():
    # Register crash handler for post-mortem analysis
    OS.set_restart_on_exit(false, [])
    
func log_performance_frame():
    if not performance_log:
        return
        
    var data = [
        Time.get_ticks_msec(),
        Performance.get_monitor(Performance.TIME_FPS),
        Performance.get_monitor(Performance.PHYSICS_2D_COLLISION_PAIRS),
        Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0,
        Performance.get_custom_monitor("thecaves/enemies"),
        Performance.get_custom_monitor("thecaves/projectiles"),
        Performance.get_monitor(Performance.TIME_PROCESS) * 1000
    ]
    
    performance_log.store_line(",".join(data.map(func(x): return str(x))))
    
    # Auto-flush every 60 frames
    if Engine.get_process_frames() % 60 == 0:
        performance_log.flush()

func log_collision_event(body_a: Node, body_b: Node, impact_force: float):
    if log_level > LogLevel.COLLISION:
        return
        
    var msg = "Collision: %s <-> %s (force: %.2f)" % [
        body_a.get_class() if body_a else "null",
        body_b.get_class() if body_b else "null",
        impact_force
    ]
    
    if collision_log:
        collision_log.store_line("[%s] %s" % [Time.get_datetime_string_from_system(), msg])

func log_with_stack_trace(level: LogLevel, message: String):
    var stack = get_stack()
    var trace = "Stack trace:\n"
    for frame in stack:
        trace += "  %s:%d in %s()\n" % [frame.source, frame.line, frame.function]
    
    _log(level, message + "\n" + trace)

func benchmark(label: String, callable: Callable) -> Variant:
    var start_time = Time.get_ticks_usec()
    var result = callable.call()
    var elapsed = Time.get_ticks_usec() - start_time
    
    log_performance("%s took %.3fms" % [label, elapsed / 1000.0], elapsed / 1000.0)
    return result
```

---

## ⚡ Enhanced Collision System Debugging

### 1. Collision Layer Debugger

```gdscript
# CollisionDebugger.gd - Visual collision analysis
extends Control

@onready var layer_grid = $VBox/LayerGrid
@onready var collision_matrix = $VBox/CollisionMatrix

var layer_names = [
    "Walls",           # Layer 1
    "Player",          # Layer 2
    "Enemy Bodies",    # Layer 3
    "Enemy Hitboxes",  # Layer 4
    "Enemy Hurtboxes", # Layer 5
    "Player Projectiles", # Layer 6
    "Enemy Projectiles",  # Layer 7
    "Pickups"            # Layer 8
]

func _ready():
    _setup_layer_visualization()
    _setup_collision_matrix()

func _setup_layer_visualization():
    for i in range(32):  # All 32 possible layers
        var row = HBoxContainer.new()
        
        var label = Label.new()
        label.text = "Layer %d: %s" % [i + 1, layer_names[i] if i < layer_names.size() else "Unused"]
        label.custom_minimum_size.x = 200
        
        var count_label = Label.new()
        count_label.name = "Count_%d" % i
        count_label.text = "0 objects"
        
        row.add_child(label)
        row.add_child(count_label)
        layer_grid.add_child(row)

func _process(_delta):
    _update_layer_counts()
    _check_collision_conflicts()

func _update_layer_counts():
    var layer_counts = {}
    
    # Count objects per layer
    for body in get_tree().get_nodes_in_group("physics_bodies"):
        if body is CollisionObject2D:
            for i in range(32):
                if body.collision_layer & (1 << i):
                    if not layer_counts.has(i):
                        layer_counts[i] = 0
                    layer_counts[i] += 1
    
    # Update display
    for i in range(32):
        var count_label = layer_grid.find_child("Count_%d" % i, true, false)
        if count_label:
            var count = layer_counts.get(i, 0)
            count_label.text = "%d objects" % count
            count_label.modulate = Color.GREEN if count < 50 else Color.YELLOW if count < 100 else Color.RED

func _check_collision_conflicts():
    # Detect common configuration errors
    var warnings = []
    
    # Check if enemies collide with each other
    var enemy_bodies = get_tree().get_nodes_in_group("enemies")
    for enemy in enemy_bodies:
        if enemy.collision_mask & (1 << 2):  # Layer 3 (Enemy Bodies)
            warnings.append("Enemy '%s' collides with other enemies!" % enemy.name)
    
    if warnings.size() > 0:
        Logger.log_warning("Collision configuration issues:\n" + "\n".join(warnings))
```

### 2. Runtime Collision Testing

```gdscript
# CollisionTester.gd - Runtime collision analysis
extends Node

func test_motion(body: PhysicsBody2D, motion: Vector2, detailed: bool = false) -> Dictionary:
    var params = PhysicsTestMotionParameters2D.new()
    params.from = body.global_transform
    params.motion = motion
    params.margin = 0.08
    params.recovery_as_collision = true  # Important for floor detection
    
    var result = PhysicsTestMotionResult2D.new()
    var collision = PhysicsServer2D.body_test_motion(body.get_rid(), params, result)
    
    var report = {
        "collision": collision,
        "safe_fraction": 0.0,
        "unsafe_fraction": 0.0,
        "remainder": Vector2.ZERO,
        "collision_point": Vector2.ZERO,
        "collision_normal": Vector2.ZERO,
        "collider": null,
        "collider_velocity": Vector2.ZERO,
        "collision_depth": 0.0
    }
    
    if collision:
        report.safe_fraction = result.get_collision_safe_fraction()
        report.unsafe_fraction = result.get_collision_unsafe_fraction()
        report.remainder = result.get_remainder()
        report.collision_point = result.get_collision_point()
        report.collision_normal = result.get_collision_normal()
        report.collider = result.get_collider()
        report.collider_velocity = result.get_collider_velocity()
        report.collision_depth = result.get_collision_depth()
        
        if detailed:
            Logger.log_collision_details(report)
    
    return report

func analyze_movement_path(body: PhysicsBody2D, target: Vector2, steps: int = 10) -> Array:
    var path_analysis = []
    var current_pos = body.global_position
    var total_motion = target - current_pos
    var step_motion = total_motion / steps
    
    for i in steps:
        var test_result = test_motion(body, step_motion * (i + 1))
        path_analysis.append({
            "step": i,
            "position": current_pos + step_motion * i,
            "collision": test_result.collision,
            "safe_distance": step_motion.length() * test_result.safe_fraction
        })
        
        if test_result.collision:
            break
    
    return path_analysis

func find_collision_exceptions(body: PhysicsBody2D) -> Array:
    if body.has_method("get_collision_exceptions"):
        return body.get_collision_exceptions()
    return []

func validate_collision_setup(body: PhysicsBody2D) -> Dictionary:
    var issues = []
    var warnings = []
    
    # Check for collision shapes
    var shapes = body.get_children().filter(func(c): return c is CollisionShape2D or c is CollisionPolygon2D)
    if shapes.is_empty():
        issues.append("No collision shapes found!")
    
    # Check layer configuration
    if body.collision_layer == 0:
        issues.append("No collision layer set!")
    
    if body.collision_mask == 0:
        warnings.append("No collision mask set - won't collide with anything")
    
    # Check for self-collision (common mistake)
    if body.collision_layer & body.collision_mask:
        warnings.append("Object can collide with its own layer")
    
    return {
        "valid": issues.is_empty(),
        "issues": issues,
        "warnings": warnings,
        "shape_count": shapes.size(),
        "layer": body.collision_layer,
        "mask": body.collision_mask
    }
```

### 3. Collision Pair Analyzer

```gdscript
# CollisionPairAnalyzer.gd - Deep collision analysis
extends Node

var collision_pairs_history: Array[int] = []
var max_history: int = 600  # 10 seconds at 60 FPS

func _physics_process(_delta):
    var current_pairs = Performance.get_monitor(Performance.PHYSICS_2D_COLLISION_PAIRS)
    collision_pairs_history.append(current_pairs)
    
    if collision_pairs_history.size() > max_history:
        collision_pairs_history.pop_front()
    
    # Analyze trends
    if Engine.get_physics_frames() % 60 == 0:  # Every second
        _analyze_collision_trends()

func _analyze_collision_trends():
    if collision_pairs_history.size() < 60:
        return
    
    var avg = collision_pairs_history.reduce(func(a, b): return a + b) / collision_pairs_history.size()
    var peak = collision_pairs_history.max()
    var current = collision_pairs_history[-1]
    
    # Detect issues
    if current > avg * 2.0:
        Logger.log_warning("Collision pairs spike: %d (avg: %d)" % [current, avg])
        _identify_collision_sources()
    
    if peak > 10000:
        Logger.log_error("Critical collision pairs peak: %d" % peak)
        _emergency_collision_reduction()

func _identify_collision_sources():
    var collision_map = {}
    
    # Categorize collision sources
    for body in get_tree().get_nodes_in_group("physics_bodies"):
        if not body is CollisionObject2D:
            continue
            
        var category = _get_body_category(body)
        if not collision_map.has(category):
            collision_map[category] = {"count": 0, "active_collisions": 0}
        
        collision_map[category].count += 1
        
        # Estimate active collisions (simplified)
        if body.has_method("get_collision_exceptions"):
            collision_map[category].active_collisions += body.get_collision_exceptions().size()
    
    # Report findings
    Logger.log_info("Collision source analysis:")
    for category in collision_map:
        var data = collision_map[category]
        Logger.log_info("  %s: %d objects, ~%d collisions" % [category, data.count, data.active_collisions])

func _get_body_category(body: Node) -> String:
    if body.is_in_group("enemies"):
        return "enemies"
    elif body.is_in_group("projectiles"):
        return "projectiles"
    elif body.is_in_group("player"):
        return "player"
    elif body.is_in_group("walls"):
        return "walls"
    else:
        return "other"

func _emergency_collision_reduction():
    Logger.log_warning("Emergency collision reduction activated!")
    
    # Disable distant enemy collisions
    for enemy in get_tree().get_nodes_in_group("enemies"):
        if enemy.has_method("get_distance_to_player"):
            if enemy.get_distance_to_player() > 1000:
                enemy.set_collision_layer_value(3, false)  # Temporarily disable
```

---

## 🎨 Advanced Shader & Neon Effect Debugging

### 1. Shader Performance Profiler

```gdscript
# ShaderProfiler.gd - Shader performance analysis
extends Node

var shader_metrics: Dictionary = {}
var gpu_timer: RID

func _ready():
    # Initialize GPU timer for shader profiling
    gpu_timer = RenderingServer.viewport_create()
    
func profile_shader(material: ShaderMaterial, test_count: int = 100) -> Dictionary:
    var results = {
        "avg_time_ms": 0.0,
        "peak_time_ms": 0.0,
        "parameters": {},
        "complexity_score": 0
    }
    
    var times = []
    
    for i in test_count:
        var start = Time.get_ticks_usec()
        
        # Force shader compilation and execution
        RenderingServer.material_set_param(material.get_rid(), "test_param", randf())
        RenderingServer.force_sync()
        
        var elapsed = Time.get_ticks_usec() - start
        times.append(elapsed / 1000.0)
    
    results.avg_time_ms = times.reduce(func(a, b): return a + b) / times.size()
    results.peak_time_ms = times.max()
    
    # Analyze shader parameters
    for param in material.get_property_list():
        if param.name.begins_with("shader_parameter/"):
            var param_name = param.name.trim_prefix("shader_parameter/")
            results.parameters[param_name] = material.get_shader_parameter(param_name)
    
    # Calculate complexity score
    results.complexity_score = _calculate_shader_complexity(material)
    
    return results

func _calculate_shader_complexity(material: ShaderMaterial) -> int:
    var score = 0
    var shader = material.shader
    
    if not shader:
        return 0
    
    var code = shader.code
    
    # Count expensive operations
    score += code.count("texture(") * 10  # Texture samples
    score += code.count("sin(") * 5        # Trig functions
    score += code.count("cos(") * 5
    score += code.count("pow(") * 8        # Power operations
    score += code.count("for(") * 20       # Loops
    score += code.count("if(") * 3         # Branches
    
    return score

func optimize_shader_lod(material: ShaderMaterial, target_ms: float = 0.5) -> void:
    var current_profile = profile_shader(material)
    
    if current_profile.avg_time_ms > target_ms:
        Logger.log_warning("Shader exceeds target: %.2fms > %.2fms" % [current_profile.avg_time_ms, target_ms])
        
        # Suggest optimizations
        var suggestions = []
        
        if current_profile.complexity_score > 100:
            suggestions.append("Reduce texture samples")
        if current_profile.complexity_score > 200:
            suggestions.append("Simplify math operations")
        if material.get_shader_parameter("quality"):
            suggestions.append("Lower quality parameter")
        
        Logger.log_info("Optimization suggestions: " + ", ".join(suggestions))
```

### 2. Neon Effect Manager Debug Tools

```gdscript
# NeonDebugOverlay.gd - Visual debugging for neon effects
extends Control

@onready var shader_list = $Panel/VBox/ShaderList
@onready var performance_graph = $Panel/VBox/PerformanceGraph

var active_shaders: Array[ShaderMaterial] = []
var frame_times: PackedFloat32Array = PackedFloat32Array()
var max_frame_times: int = 120

func _ready():
    custom_minimum_size = Vector2(400, 600)
    _setup_ui()

func _setup_ui():
    # Create shader parameter sliders
    for i in 5:
        var slider_container = HBoxContainer.new()
        
        var label = Label.new()
        label.text = "Shader %d intensity:" % i
        label.custom_minimum_size.x = 150
        
        var slider = HSlider.new()
        slider.min_value = 0.0
        slider.max_value = 3.0
        slider.value = 1.0
        slider.step = 0.1
        slider.name = "ShaderSlider_%d" % i
        slider.value_changed.connect(_on_shader_intensity_changed.bind(i))
        
        var value_label = Label.new()
        value_label.text = "1.0"
        value_label.name = "ValueLabel_%d" % i
        
        slider_container.add_child(label)
        slider_container.add_child(slider)
        slider_container.add_child(value_label)
        
        shader_list.add_child(slider_container)

func _on_shader_intensity_changed(value: float, shader_index: int):
    if shader_index < active_shaders.size():
        active_shaders[shader_index].set_shader_parameter("intensity", value)
        
        var value_label = shader_list.find_child("ValueLabel_%d" % shader_index, true, false)
        if value_label:
            value_label.text = "%.1f" % value

func register_shader(shader: ShaderMaterial):
    if not shader in active_shaders:
        active_shaders.append(shader)
        _analyze_shader(shader)

func _analyze_shader(shader: ShaderMaterial):
    var analysis = {
        "param_count": 0,
        "texture_count": 0,
        "estimated_cost": 0
    }
    
    for prop in shader.get_property_list():
        if prop.name.begins_with("shader_parameter/"):
            analysis.param_count += 1
            
            var value = shader.get_shader_parameter(prop.name.trim_prefix("shader_parameter/"))
            if value is Texture2D:
                analysis.texture_count += 1
    
    analysis.estimated_cost = analysis.param_count * 2 + analysis.texture_count * 10
    
    Logger.log_info("Shader analysis: %s" % analysis)

func _draw():
    if frame_times.size() < 2:
        return
    
    # Draw performance graph
    var graph_rect = Rect2(10, 400, 380, 180)
    draw_rect(graph_rect, Color(0.1, 0.1, 0.1, 0.8))
    
    # Draw frame time line
    var points = PackedVector2Array()
    for i in frame_times.size():
        var x = graph_rect.position.x + (i / float(max_frame_times)) * graph_rect.size.x
        var y = graph_rect.position.y + graph_rect.size.y - (frame_times[i] / 33.33) * graph_rect.size.y
        points.append(Vector2(x, y))
    
    if points.size() > 1:
        draw_polyline(points, Color.CYAN, 2.0)
    
    # Draw target line (16.67ms)
    var target_y = graph_rect.position.y + graph_rect.size.y - (16.67 / 33.33) * graph_rect.size.y
    draw_line(
        Vector2(graph_rect.position.x, target_y),
        Vector2(graph_rect.position.x + graph_rect.size.x, target_y),
        Color.GREEN,
        1.0
    )

func _process(_delta):
    # Update frame time graph
    var frame_time = Performance.get_monitor(Performance.TIME_PROCESS) * 1000
    frame_times.append(frame_time)
    
    if frame_times.size() > max_frame_times:
        frame_times.remove_at(0)
    
    queue_redraw()
```

---

## 🏊 Enhanced Object Pooling Debugging

### 1. Pool Analytics System

```gdscript
# PoolAnalytics.gd - Detailed pool performance tracking
extends Node

var pool_stats: Dictionary = {}
var allocation_history: Array = []
var peak_usage: Dictionary = {}

func track_allocation(pool_name: String, object: Node):
    if not pool_stats.has(pool_name):
        pool_stats[pool_name] = {
            "total_allocations": 0,
            "current_active": 0,
            "reuse_count": 0,
            "exhaustion_count": 0,
            "avg_lifetime": 0.0,
            "peak_active": 0
        }
    
    var stats = pool_stats[pool_name]
    stats.total_allocations += 1
    stats.current_active += 1
    stats.peak_active = max(stats.peak_active, stats.current_active)
    
    # Track individual allocation
    allocation_history.append({
        "pool": pool_name,
        "object": object.get_instance_id(),
        "timestamp": Time.get_ticks_msec(),
        "active": true
    })
    
    # Trim history if too large
    if allocation_history.size() > 10000:
        allocation_history = allocation_history.slice(-5000)

func track_return(pool_name: String, object: Node):
    if not pool_stats.has(pool_name):
        return
    
    var stats = pool_stats[pool_name]
    stats.current_active -= 1
    stats.reuse_count += 1
    
    # Calculate lifetime
    for i in range(allocation_history.size() - 1, -1, -1):
        var alloc = allocation_history[i]
        if alloc.object == object.get_instance_id() and alloc.active:
            var lifetime = Time.get_ticks_msec() - alloc.timestamp
            stats.avg_lifetime = (stats.avg_lifetime + lifetime) / 2.0
            alloc.active = false
            break

func track_exhaustion(pool_name: String):
    if pool_stats.has(pool_name):
        pool_stats[pool_name].exhaustion_count += 1
        Logger.log_warning("Pool exhausted: %s (count: %d)" % [pool_name, pool_stats[pool_name].exhaustion_count])

func get_pool_report() -> String:
    var report = "=== Pool Performance Report ===\n"
    
    for pool_name in pool_stats:
        var stats = pool_stats[pool_name]
        report += "\n%s:\n" % pool_name
        report += "  Active: %d/%d (peak: %d)\n" % [stats.current_active, stats.total_allocations, stats.peak_active]
        report += "  Reuse rate: %.1f%%\n" % ((stats.reuse_count / float(max(stats.total_allocations, 1))) * 100)
        report += "  Avg lifetime: %.1fms\n" % stats.avg_lifetime
        report += "  Exhaustions: %d\n" % stats.exhaustion_count
        
        # Recommendations
        if stats.exhaustion_count > 0:
            var suggested_size = stats.peak_active * 1.5
            report += "  ⚠️ Increase pool size to %d\n" % suggested_size
        
        if stats.avg_lifetime > 5000:
            report += "  ⚠️ Objects held too long (>5s)\n"
    
    return report

func visualize_pool_usage() -> Texture2D:
    # Create a visual representation of pool usage over time
    var image = Image.create(600, 200, false, Image.FORMAT_RGB8)
    image.fill(Color.BLACK)
    
    # Draw usage graph for each pool
    var y_offset = 0
    for pool_name in pool_stats:
        var stats = pool_stats[pool_name]
        var color = Color.from_hsv(randf(), 0.8, 0.9)
        
        # Draw usage bar
        var width = int((stats.current_active / float(max(stats.peak_active, 1))) * 580)
        for x in width:
            for y in 30:
                image.set_pixel(x + 10, y + y_offset + 10, color)
        
        y_offset += 40
    
    return ImageTexture.create_from_image(image)
```

### 2. Pool Memory Tracker

```gdscript
# PoolMemoryTracker.gd - Memory usage tracking for pools
extends Node

var memory_snapshots: Array[Dictionary] = []
var snapshot_interval: float = 1.0  # Seconds
var snapshot_timer: float = 0.0

func _ready():
    set_process(true)

func _process(delta):
    snapshot_timer += delta
    if snapshot_timer >= snapshot_interval:
        snapshot_timer = 0.0
        take_memory_snapshot()

func take_memory_snapshot():
    var snapshot = {
        "timestamp": Time.get_ticks_msec(),
        "total_memory": Performance.get_monitor(Performance.MEMORY_STATIC),
        "pools": {}
    }
    
    # Track each pool's memory
    for pool_name in ["swarm", "shooter", "tank", "projectile", "particle"]:
        snapshot.pools[pool_name] = estimate_pool_memory(pool_name)
    
    memory_snapshots.append(snapshot)
    
    # Keep only last 5 minutes of data
    if memory_snapshots.size() > 300:
        memory_snapshots.pop_front()
    
    # Check for memory leaks
    detect_memory_leaks()

func estimate_pool_memory(pool_name: String) -> int:
    var pool = EnemyPool.pools.get(pool_name, [])
    var estimated_bytes = 0
    
    for object in pool:
        # Base object size
        estimated_bytes += 1024  # Base Node2D overhead
        
        # Add component sizes
        if object.has_node("Sprite2D"):
            var sprite = object.get_node("Sprite2D")
            if sprite.texture:
                estimated_bytes += sprite.texture.get_image().get_data().size()
        
        # Add script variables (rough estimate)
        estimated_bytes += 256 * object.get_property_list().size()
    
    return estimated_bytes

func detect_memory_leaks():
    if memory_snapshots.size() < 10:
        return
    
    # Compare current to 1 minute ago
    var current = memory_snapshots[-1]
    var past = memory_snapshots[max(0, memory_snapshots.size() - 60)]
    
    var growth = current.total_memory - past.total_memory
    var growth_rate = growth / float(past.total_memory) * 100
    
    if growth_rate > 10:  # 10% growth in 1 minute
        Logger.log_warning("Potential memory leak detected: +%.1f%% in 60s" % growth_rate)
        
        # Identify which pool is growing
        for pool_name in current.pools:
            var current_size = current.pools[pool_name]
            var past_size = past.pools.get(pool_name, 0)
            var pool_growth = current_size - past_size
            
            if pool_growth > 1048576:  # 1MB growth
                Logger.log_warning("  Pool '%s' grew by %.1fMB" % [pool_name, pool_growth / 1048576.0])
```

---

## 🤖 Claude Code & MCP Integration

### 1. Enhanced MCP Setup for Debugging

```gdscript
# MCPDebugInterface.gd - Remote debugging via MCP
extends Node

var mcp_server: TCPServer
var debug_clients: Array[StreamPeerTCP] = []
var command_queue: Array[Dictionary] = []

func _ready():
    start_debug_server()

func start_debug_server(port: int = 9999):
    mcp_server = TCPServer.new()
    mcp_server.listen(port)
    Logger.log_info("MCP Debug server listening on port %d" % port)

func _process(_delta):
    # Accept new connections
    if mcp_server.is_connection_available():
        var client = mcp_server.take_connection()
        debug_clients.append(client)
        Logger.log_info("Debug client connected")
    
    # Process client commands
    for client in debug_clients:
        if client.get_status() != StreamPeerTCP.STATUS_CONNECTED:
            debug_clients.erase(client)
            continue
        
        if client.get_available_bytes() > 0:
            var command = client.get_string(client.get_available_bytes())
            _process_debug_command(command, client)

func _process_debug_command(command_str: String, client: StreamPeerTCP):
    var parts = command_str.split(" ")
    var cmd = parts[0]
    var args = parts.slice(1)
    
    match cmd:
        "profile":
            var profile_data = get_performance_profile()
            client.put_string(JSON.stringify(profile_data))
        
        "collision":
            var collision_data = get_collision_analysis()
            client.put_string(JSON.stringify(collision_data))
        
        "pool":
            var pool_report = PoolAnalytics.get_pool_report()
            client.put_string(pool_report)
        
        "spawn":
            if args.size() >= 2:
                spawn_test_enemies(int(args[0]), args[1])
                client.put_string("Spawned %s enemies of type %s" % [args[0], args[1]])
        
        "clear":
            clear_all_enemies()
            client.put_string("Cleared all enemies")
        
        "set":
            if args.size() >= 2:
                set_debug_parameter(args[0], args[1])
                client.put_string("Set %s to %s" % [args[0], args[1]])
        
        "get":
            if args.size() >= 1:
                var value = get_debug_parameter(args[0])
                client.put_string(str(value))
        
        _:
            client.put_string("Unknown command: " + cmd)

func get_performance_profile() -> Dictionary:
    return {
        "fps": Performance.get_monitor(Performance.TIME_FPS),
        "collision_pairs": Performance.get_monitor(Performance.PHYSICS_2D_COLLISION_PAIRS),
        "memory_mb": Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0,
        "enemies": get_tree().get_nodes_in_group("enemies").size(),
        "projectiles": get_tree().get_nodes_in_group("projectiles").size(),
        "frame_time_ms": Performance.get_monitor(Performance.TIME_PROCESS) * 1000,
        "physics_time_ms": Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000,
        "draw_calls": Performance.get_monitor(Performance.RENDER_2D_DRAW_CALLS_IN_FRAME)
    }

func get_collision_analysis() -> Dictionary:
    var analyzer = CollisionPairAnalyzer.new()
    return {
        "current_pairs": Performance.get_monitor(Performance.PHYSICS_2D_COLLISION_PAIRS),
        "history": analyzer.collision_pairs_history,
        "average": analyzer.collision_pairs_history.reduce(func(a, b): return a + b) / max(analyzer.collision_pairs_history.size(), 1),
        "peak": analyzer.collision_pairs_history.max() if analyzer.collision_pairs_history.size() > 0 else 0
    }
```

### 2. AI-Powered Debug Commands

```gdscript
# AIDebugAssistant.gd - Claude-powered debugging
extends Node

const CLAUDE_PROMPTS = {
    "analyze_performance": """
    Analyze this performance data and identify bottlenecks:
    FPS: {fps}
    Collision Pairs: {collision_pairs}
    Memory: {memory_mb}MB
    Enemies: {enemies}
    Frame Time: {frame_time}ms
    
    Provide specific optimization suggestions for a roguelite with 100+ enemies.
    """,
    
    "optimize_collision": """
    Current collision setup:
    Layers: {layers}
    Collision pairs: {pairs}
    Enemy count: {enemies}
    
    Suggest collision layer optimizations to reduce pairs below 5000.
    """,
    
    "debug_shader": """
    Shader performance metrics:
    Complexity score: {complexity}
    Avg time: {avg_time}ms
    Peak time: {peak_time}ms
    Parameters: {parameters}
    
    Suggest shader optimizations for better performance.
    """,
    
    "memory_leak": """
    Memory growth detected:
    Start: {start_memory}MB
    Current: {current_memory}MB
    Duration: {duration}s
    Pool stats: {pool_stats}
    
    Identify potential memory leak sources and solutions.
    """
}

func request_ai_analysis(analysis_type: String, data: Dictionary) -> String:
    if not CLAUDE_PROMPTS.has(analysis_type):
        return "Unknown analysis type"
    
    var prompt = CLAUDE_PROMPTS[analysis_type]
    
    # Format prompt with data
    for key in data:
        prompt = prompt.replace("{%s}" % key, str(data[key]))
    
    # Here you would normally send to Claude API
    # For now, return formatted prompt
    Logger.log_info("AI Debug Request: " + analysis_type)
    return prompt

func analyze_performance_with_ai():
    var data = {
        "fps": Performance.get_monitor(Performance.TIME_FPS),
        "collision_pairs": Performance.get_monitor(Performance.PHYSICS_2D_COLLISION_PAIRS),
        "memory_mb": Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0,
        "enemies": get_tree().get_nodes_in_group("enemies").size(),
        "frame_time": Performance.get_monitor(Performance.TIME_PROCESS) * 1000
    }
    
    return request_ai_analysis("analyze_performance", data)
```

---

## 🧪 Automated Testing Framework

### 1. Performance Regression Tests

```gdscript
# test/test_performance.gd - GdUnit4 performance tests
extends GdUnitTestSuite

var baseline_metrics = {
    "spawn_100_enemies_ms": 50,
    "collision_pairs_100_enemies": 3000,
    "memory_100_enemies_mb": 150,
    "frame_time_combat_ms": 16.67
}

func before_test():
    # Setup clean test environment
    get_tree().call_group("enemies", "queue_free")
    get_tree().call_group("projectiles", "queue_free")
    await get_tree().process_frame

func test_enemy_spawn_performance():
    var start_time = Time.get_ticks_msec()
    
    for i in 100:
        var enemy = EnemyPool.get_entity("swarm")
        enemy.global_position = Vector2(randf() * 1920, randf() * 1080)
    
    var elapsed = Time.get_ticks_msec() - start_time
    
    assert_that(elapsed).is_less(baseline_metrics.spawn_100_enemies_ms)
    
    if elapsed > baseline_metrics.spawn_100_enemies_ms * 0.8:
        push_warning("Spawn performance degrading: %dms (baseline: %dms)" % [elapsed, baseline_metrics.spawn_100_enemies_ms])

func test_collision_pairs_limit():
    # Spawn enemies
    for i in 100:
        var enemy = EnemyPool.get_entity("swarm")
        enemy.global_position = Vector2(randf() * 1000, randf() * 1000)
    
    # Wait for physics to settle
    await get_tree().physics_frame
    await get_tree().physics_frame
    
    var collision_pairs = Performance.get_monitor(Performance.PHYSICS_2D_COLLISION_PAIRS)
    
    assert_that(collision_pairs).is_less(baseline_metrics.collision_pairs_100_enemies)
    
    if collision_pairs > 5000:
        fail("Critical: Collision pairs exceed safe limit: %d" % collision_pairs)

func test_memory_usage():
    var start_memory = Performance.get_monitor(Performance.MEMORY_STATIC)
    
    # Spawn enemies
    for i in 100:
        var enemy = EnemyPool.get_entity("swarm")
        enemy.global_position = Vector2(randf() * 1920, randf() * 1080)
    
    await get_tree().process_frame
    
    var end_memory = Performance.get_monitor(Performance.MEMORY_STATIC)
    var memory_increase_mb = (end_memory - start_memory) / 1048576.0
    
    assert_that(memory_increase_mb).is_less(baseline_metrics.memory_100_enemies_mb)

func test_frame_time_under_load():
    # Spawn enemies
    for i in 150:
        var enemy = EnemyPool.get_entity("swarm")
        enemy.global_position = Vector2(randf() * 1920, randf() * 1080)
    
    # Spawn projectiles
    for i in 200:
        var proj = ProjectileManager.spawn_projectile(
            Vector2(randf() * 1920, randf() * 1080),
            Vector2.RIGHT.rotated(randf() * TAU),
            300,
            10
        )
    
    # Measure frame time over 60 frames
    var frame_times = []
    for i in 60:
        var start = Time.get_ticks_usec()
        await get_tree().process_frame
        var elapsed = (Time.get_ticks_usec() - start) / 1000.0
        frame_times.append(elapsed)
    
    var avg_frame_time = frame_times.reduce(func(a, b): return a + b) / frame_times.size()
    
    assert_that(avg_frame_time).is_less(baseline_metrics.frame_time_combat_ms)

func test_lod_system_performance():
    var player = preload("res://entities/Player.tscn").instantiate()
    player.global_position = Vector2(960, 540)
    add_child(player)
    
    # Spawn enemies at various distances
    for i in 200:
        var enemy = EnemyPool.get_entity("swarm")
        var angle = (i / 200.0) * TAU
        var distance = 100 + i * 10  # Spreading from 100 to 2100 pixels
        enemy.global_position = player.global_position + Vector2.RIGHT.rotated(angle) * distance
    
    await get_tree().process_frame
    
    # Check LOD distribution
    var lod_counts = {
        Enemy.LOD.FULL: 0,
        Enemy.LOD.MEDIUM: 0,
        Enemy.LOD.LOW: 0,
        Enemy.LOD.MINIMAL: 0,
        Enemy.LOD.DISABLED: 0
    }
    
    for enemy in get_tree().get_nodes_in_group("enemies"):
        lod_counts[enemy.current_lod] += 1
    
    # Most enemies should be in lower LOD levels
    var low_detail_ratio = (lod_counts[Enemy.LOD.LOW] + lod_counts[Enemy.LOD.MINIMAL] + lod_counts[Enemy.LOD.DISABLED]) / 200.0
    assert_that(low_detail_ratio).is_greater(0.6)  # At least 60% in low detail
    
    player.queue_free()

func test_pool_exhaustion_handling():
    # Intentionally exhaust pool
    var spawned = []
    for i in 150:  # More than pool size
        var enemy = EnemyPool.get_entity("swarm")
        if enemy:
            spawned.append(enemy)
    
    # Should handle gracefully without crashing
    assert_that(spawned.size()).is_greater(0)
    
    # Check if pool recycling works
    var last_enemy = spawned[-1]
    assert_that(last_enemy).is_not_null()
```

### 2. Collision System Tests

```gdscript
# test/test_collision_optimization.gd
extends GdUnitTestSuite

func test_enemy_no_self_collision():
    var enemy1 = preload("res://entities/enemies/SwarmEnemy.tscn").instantiate()
    var enemy2 = preload("res://entities/enemies/SwarmEnemy.tscn").instantiate()
    
    add_child(enemy1)
    add_child(enemy2)
    
    # Check collision layers
    assert_that(enemy1.collision_layer).is_equal(4)  # Enemy layer
    assert_that(enemy1.collision_mask & 4).is_equal(0)  # Should NOT collide with own layer
    
    enemy1.queue_free()
    enemy2.queue_free()

func test_collision_layer_setup():
    var validator = CollisionTester.new()
    
    # Test player setup
    var player = preload("res://entities/Player.tscn").instantiate()
    add_child(player)
    
    var player_validation = validator.validate_collision_setup(player)
    assert_that(player_validation.valid).is_true()
    assert_that(player_validation.warnings).is_empty()
    
    player.queue_free()

func test_motion_collision_detection():
    var tester = CollisionTester.new()
    var enemy = preload("res://entities/enemies/SwarmEnemy.tscn").instantiate()
    
    add_child(enemy)
    enemy.global_position = Vector2(500, 500)
    
    # Test motion toward wall
    var wall = StaticBody2D.new()
    var wall_shape = CollisionShape2D.new()
    wall_shape.shape = RectangleShape2D.new()
    wall_shape.shape.size = Vector2(100, 600)
    wall.add_child(wall_shape)
    wall.global_position = Vector2(700, 500)
    add_child(wall)
    
    await get_tree().physics_frame
    
    var motion_result = tester.test_motion(enemy, Vector2(300, 0))
    
    assert_that(motion_result.collision).is_true()
    assert_that(motion_result.safe_fraction).is_greater(0)
    assert_that(motion_result.safe_fraction).is_less(1)
    
    enemy.queue_free()
    wall.queue_free()
```

---

## 📊 Debug Visualization Tools

### 1. Performance Overlay HUD

```gdscript
# DebugHUD.gd - Enhanced debug overlay
extends Control

@onready var fps_label = $Panel/Grid/FPSLabel
@onready var collision_label = $Panel/Grid/CollisionLabel
@onready var memory_label = $Panel/Grid/MemoryLabel
@onready var enemies_label = $Panel/Grid/EnemiesLabel
@onready var draw_calls_label = $Panel/Grid/DrawCallsLabel
@onready var frame_graph = $Panel/FrameGraph
@onready var collision_graph = $Panel/CollisionGraph

var frame_history: PackedFloat32Array = PackedFloat32Array()
var collision_history: PackedInt32Array = PackedInt32Array()
var history_size: int = 120

var show_detailed: bool = false
var show_graphs: bool = true

func _ready():
    visible = OS.is_debug_build()
    
    # Setup custom theme
    var panel_style = StyleBoxFlat.new()
    panel_style.bg_color = Color(0, 0, 0, 0.8)
    panel_style.corner_radius_top_left = 5
    panel_style.corner_radius_top_right = 5
    $Panel.add_theme_stylebox_override("panel", panel_style)

func _input(event):
    if event.is_action_pressed("debug_toggle"):  # F3
        visible = !visible
    elif event.is_action_pressed("debug_detail"):  # F4
        show_detailed = !show_detailed
    elif event.is_action_pressed("debug_graphs"):  # F5
        show_graphs = !show_graphs
        frame_graph.visible = show_graphs
        collision_graph.visible = show_graphs

func _process(_delta):
    if not visible:
        return
    
    update_metrics()
    update_history()
    
    if show_graphs:
        frame_graph.queue_redraw()
        collision_graph.queue_redraw()

func update_metrics():
    # FPS with color coding
    var fps = Engine.get_frames_per_second()
    fps_label.text = "FPS: %d" % fps
    fps_label.modulate = get_metric_color(fps, 55, 45, true)
    
    # Collision pairs (CRITICAL!)
    var collision_pairs = Performance.get_monitor(Performance.PHYSICS_2D_COLLISION_PAIRS)
    collision_label.text = "Collisions: %d" % collision_pairs
    collision_label.modulate = get_metric_color(collision_pairs, 5000, 8000, false)
    
    # Memory
    var memory_mb = Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0
    var memory_peak_mb = Performance.get_monitor(Performance.MEMORY_STATIC_MAX) / 1048576.0
    memory_label.text = "Mem: %.1f/%.1fMB" % [memory_mb, memory_peak_mb]
    memory_label.modulate = get_metric_color(memory_mb, 200, 400, false)
    
    # Entity counts
    var enemies = get_tree().get_nodes_in_group("enemies").size()
    var projectiles = get_tree().get_nodes_in_group("projectiles").size()
    enemies_label.text = "E: %d P: %d" % [enemies, projectiles]
    
    # Draw calls
    var draw_calls = Performance.get_monitor(Performance.RENDER_2D_DRAW_CALLS_IN_FRAME)
    draw_calls_label.text = "Draw: %d" % draw_calls
    draw_calls_label.modulate = get_metric_color(draw_calls, 1000, 2000, false)
    
    if show_detailed:
        update_detailed_metrics()

func update_detailed_metrics():
    # Add more detailed metrics
    var details = "\n"
    details += "Frame: %.2fms\n" % (Performance.get_monitor(Performance.TIME_PROCESS) * 1000)
    details += "Physics: %.2fms\n" % (Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000)
    details += "Texture: %.1fMB\n" % (Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED) / 1048576.0)
    details += "Pool: %.1f%%\n" % Performance.get_custom_monitor("thecaves/pool_usage")
    details += "LOD Low: %.1f%%\n" % Performance.get_custom_monitor("thecaves/lod_distribution")
    
    $Panel/DetailLabel.text = details
    $Panel/DetailLabel.visible = true

func get_metric_color(value: float, warning_threshold: float, critical_threshold: float, higher_is_better: bool) -> Color:
    if higher_is_better:
        if value >= warning_threshold:
            return Color.GREEN
        elif value >= critical_threshold:
            return Color.YELLOW
        else:
            return Color.RED
    else:
        if value <= warning_threshold:
            return Color.GREEN
        elif value <= critical_threshold:
            return Color.YELLOW
        else:
            return Color.RED

func update_history():
    # Update frame time history
    var frame_time = Performance.get_monitor(Performance.TIME_PROCESS) * 1000
    frame_history.append(frame_time)
    if frame_history.size() > history_size:
        frame_history.remove_at(0)
    
    # Update collision history
    var collision_pairs = Performance.get_monitor(Performance.PHYSICS_2D_COLLISION_PAIRS)
    collision_history.append(collision_pairs)
    if collision_history.size() > history_size:
        collision_history.remove_at(0)

func _on_frame_graph_draw():
    draw_graph(frame_graph, frame_history, 33.33, Color.CYAN, 16.67)

func _on_collision_graph_draw():
    draw_graph(collision_graph, collision_history, 10000, Color.ORANGE, 5000)

func draw_graph(canvas: Control, data: Array, max_value: float, color: Color, target_value: float):
    var size = canvas.size
    
    # Background
    canvas.draw_rect(Rect2(Vector2.ZERO, size), Color(0.1, 0.1, 0.1, 0.5))
    
    if data.size() < 2:
        return
    
    # Draw data line
    var points = PackedVector2Array()
    for i in data.size():
        var x = (i / float(history_size)) * size.x
        var y = size.y - (data[i] / max_value) * size.y
        points.append(Vector2(x, y))
    
    canvas.draw_polyline(points, color, 2.0, true)
    
    # Draw target line
    var target_y = size.y - (target_value / max_value) * size.y
    canvas.draw_line(Vector2(0, target_y), Vector2(size.x, target_y), Color.GREEN, 1.0)
```

### 2. Collision Visualizer

```gdscript
# CollisionVisualizer.gd - Runtime collision shape visualization
extends Node2D

var draw_collision_shapes: bool = true
var draw_collision_pairs: bool = false
var draw_layer_colors: bool = true
var collision_pairs: Array = []

var layer_colors = [
    Color.WHITE,        # Layer 1: Walls
    Color.BLUE,         # Layer 2: Player
    Color.RED,          # Layer 3: Enemy Bodies
    Color.ORANGE,       # Layer 4: Enemy Hitboxes
    Color.YELLOW,       # Layer 5: Enemy Hurtboxes
    Color.CYAN,         # Layer 6: Player Projectiles
    Color.MAGENTA,      # Layer 7: Enemy Projectiles
    Color.GREEN         # Layer 8: Pickups
]

func _ready():
    set_process(true)
    z_index = 1000  # Draw on top

func _draw():
    if not OS.is_debug_build():
        return
    
    if draw_collision_shapes:
        _draw_all_collision_shapes()
    
    if draw_collision_pairs:
        _draw_active_collision_pairs()

func _draw_all_collision_shapes():
    for body in get_tree().get_nodes_in_group("physics_bodies"):
        if not body is CollisionObject2D:
            continue
        
        var color = _get_body_color(body)
        
        for child in body.get_children():
            if child is CollisionShape2D:
                _draw_collision_shape(child, color)
            elif child is CollisionPolygon2D:
                _draw_collision_polygon(child, color)

func _draw_collision_shape(shape_node: CollisionShape2D, color: Color):
    var shape = shape_node.shape
    if not shape:
        return
    
    var transform = shape_node.global_transform
    
    if shape is CircleShape2D:
        draw_circle(transform.origin, shape.radius, Color(color.r, color.g, color.b, 0.3))
        draw_arc(transform.origin, shape.radius, 0, TAU, 32, color, 2.0)
    
    elif shape is RectangleShape2D:
        var rect = Rect2(transform.origin - shape.size / 2, shape.size)
        draw_rect(rect, Color(color.r, color.g, color.b, 0.3))
        draw_rect(rect, color, false, 2.0)
    
    elif shape is CapsuleShape2D:
        # Simplified capsule drawing
        var height = shape.height
        var radius = shape.radius
        draw_circle(transform.origin + Vector2(0, -height/2), radius, Color(color.r, color.g, color.b, 0.3))
        draw_circle(transform.origin + Vector2(0, height/2), radius, Color(color.r, color.g, color.b, 0.3))
        draw_rect(Rect2(transform.origin.x - radius, transform.origin.y - height/2, radius * 2, height), Color(color.r, color.g, color.b, 0.3))

func _draw_collision_polygon(polygon_node: CollisionPolygon2D, color: Color):
    var points = polygon_node.polygon
    if points.size() < 3:
        return
    
    var transform = polygon_node.global_transform
    var transformed_points = PackedVector2Array()
    
    for point in points:
        transformed_points.append(transform * point)
    
    draw_colored_polygon(transformed_points, Color(color.r, color.g, color.b, 0.3))
    draw_polyline(transformed_points, color, 2.0, true)

func _get_body_color(body: CollisionObject2D) -> Color:
    if not draw_layer_colors:
        return Color.WHITE
    
    # Find first active layer
    for i in range(8):
        if body.collision_layer & (1 << i):
            return layer_colors[i]
    
    return Color.GRAY

func _draw_active_collision_pairs():
    # This would require tracking actual collision pairs
    # Simplified version: draw lines between nearby enemies
    var enemies = get_tree().get_nodes_in_group("enemies")
    
    for i in enemies.size():
        for j in range(i + 1, min(i + 5, enemies.size())):  # Check only nearby
            var dist = enemies[i].global_position.distance_to(enemies[j].global_position)
            if dist < 100:
                draw_line(enemies[i].global_position, enemies[j].global_position, Color(1, 0, 0, 0.2), 1.0)
```

---

## 🚨 Common Issues & Solutions

### Issue: FPS Drops Below 30

```gdscript
# EmergencyOptimizer.gd - Automatic performance recovery
extends Node

var emergency_mode: bool = false
var performance_history: Array[float] = []

func _ready():
    set_process(true)

func _process(_delta):
    var fps = Engine.get_frames_per_second()
    performance_history.append(fps)
    
    if performance_history.size() > 60:
        performance_history.pop_front()
    
    # Check for sustained low FPS
    if performance_history.size() >= 30:
        var avg_fps = performance_history.reduce(func(a, b): return a + b) / performance_history.size()
        
        if avg_fps < 40 and not emergency_mode:
            activate_emergency_mode()
        elif avg_fps > 55 and emergency_mode:
            deactivate_emergency_mode()

func activate_emergency_mode():
    emergency_mode = true
    Logger.log_warning("EMERGENCY MODE ACTIVATED - Low FPS detected")
    
    # Reduce visual quality
    RenderingServer.global_shader_parameter_set("neon_quality", 0)
    
    # Reduce enemy count
    var enemies = get_tree().get_nodes_in_group("enemies")
    var to_remove = enemies.size() / 3
    for i in to_remove:
        if i < enemies.size():
            enemies[i].queue_free()
    
    # Disable distant enemy collisions
    for enemy in get_tree().get_nodes_in_group("enemies"):
        if enemy.has_method("set_emergency_mode"):
            enemy.set_emergency_mode(true)
    
    # Clear unnecessary projectiles
    var projectiles = get_tree().get_nodes_in_group("projectiles")
    for i in range(projectiles.size() / 2, projectiles.size()):
        if i < projectiles.size():
            projectiles[i].queue_free()

func deactivate_emergency_mode():
    emergency_mode = false
    Logger.log_info("Emergency mode deactivated - Performance recovered")
    
    RenderingServer.global_shader_parameter_set("neon_quality", 2)
    
    for enemy in get_tree().get_nodes_in_group("enemies"):
        if enemy.has_method("set_emergency_mode"):
            enemy.set_emergency_mode(false)
```

### Issue: Memory Leaks

```gdscript
# MemoryLeakDetector.gd - Automated leak detection
extends Node

var tracked_objects: Dictionary = {}
var leak_report: Dictionary = {}

func track_object(obj: Object, category: String = "general"):
    var id = obj.get_instance_id()
    tracked_objects[id] = {
        "object": weakref(obj),
        "category": category,
        "created": Time.get_ticks_msec(),
        "stack": get_stack()
    }

func untrack_object(obj: Object):
    var id = obj.get_instance_id()
    tracked_objects.erase(id)

func check_for_leaks():
    var current_time = Time.get_ticks_msec()
    leak_report.clear()
    
    for id in tracked_objects:
        var data = tracked_objects[id]
        var weak_obj = data.object
        
        if not weak_obj.get_ref():
            # Object was freed properly
            tracked_objects.erase(id)
            continue
        
        var lifetime = current_time - data.created
        if lifetime > 60000:  # Object alive for > 1 minute
            if not leak_report.has(data.category):
                leak_report[data.category] = []
            
            leak_report[data.category].append({
                "lifetime_ms": lifetime,
                "stack": data.stack
            })
    
    if leak_report.size() > 0:
        Logger.log_warning("Potential memory leaks detected:")
        for category in leak_report:
            Logger.log_warning("  %s: %d objects" % [category, leak_report[category].size()])

func get_memory_snapshot() -> Dictionary:
    return {
        "static": Performance.get_monitor(Performance.MEMORY_STATIC),
        "dynamic": Performance.get_monitor(Performance.MEMORY_DYNAMIC),
        "static_max": Performance.get_monitor(Performance.MEMORY_STATIC_MAX),
        "dynamic_max": Performance.get_monitor(Performance.MEMORY_DYNAMIC_MAX),
        "message_buffer": Performance.get_monitor(Performance.MEMORY_MESSAGE_BUFFER_MAX),
        "tracked_objects": tracked_objects.size(),
        "categories": _get_category_counts()
    }

func _get_category_counts() -> Dictionary:
    var counts = {}
    for id in tracked_objects:
        var category = tracked_objects[id].category
        if not counts.has(category):
            counts[category] = 0
        counts[category] += 1
    return counts
```

---

## 📚 Quick Debug Commands Reference

### Console Commands
```gdscript
# In-game console commands
spawn [count] [type]        # Spawn test enemies
clear                        # Clear all enemies
profile                      # Show performance profile
collision                    # Analyze collision pairs
pool                        # Show pool statistics
shader [quality]            # Set shader quality (0-3)
lod [enable/disable]        # Toggle LOD system
emergency                   # Toggle emergency mode
memory                      # Show memory usage
export_metrics              # Export performance data
stress [level]              # Run stress test (1-5)
```

### Hotkeys
```
F3  - Toggle debug HUD
F4  - Toggle detailed metrics
F5  - Toggle performance graphs
F6  - Toggle collision visualization
F7  - Export performance report
F8  - Run quick stress test
F9  - Toggle shader debugger
F10 - Emergency performance mode
F11 - Memory leak check
F12 - Screenshot with debug info
```

---

## 🎯 Success Metrics & Monitoring

### Performance Dashboard

```gdscript
# PerformanceDashboard.gd - Central monitoring
extends Control

signal performance_threshold_exceeded(metric: String, value: float)

var thresholds = {
    "fps": {"min": 55, "target": 60},
    "collision_pairs": {"max": 5000, "target": 3000},
    "memory_mb": {"max": 300, "target": 150},
    "frame_time_ms": {"max": 18, "target": 16.67},
    "enemies": {"max": 200, "target": 150}
}

var current_metrics = {}
var alerts = []

func _ready():
    _start_monitoring()

func _start_monitoring():
    var timer = Timer.new()
    timer.wait_time = 0.1
    timer.timeout.connect(_update_metrics)
    add_child(timer)
    timer.start()

func _update_metrics():
    current_metrics = {
        "fps": Performance.get_monitor(Performance.TIME_FPS),
        "collision_pairs": Performance.get_monitor(Performance.PHYSICS_2D_COLLISION_PAIRS),
        "memory_mb": Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0,
        "frame_time_ms": Performance.get_monitor(Performance.TIME_PROCESS) * 1000,
        "enemies": get_tree().get_nodes_in_group("enemies").size()
    }
    
    _check_thresholds()
    _update_display()

func _check_thresholds():
    alerts.clear()
    
    for metric in thresholds:
        var value = current_metrics[metric]
        var limits = thresholds[metric]
        
        if limits.has("min") and value < limits.min:
            alerts.append("%s below minimum: %.1f < %.1f" % [metric, value, limits.min])
            performance_threshold_exceeded.emit(metric, value)
        
        if limits.has("max") and value > limits.max:
            alerts.append("%s above maximum: %.1f > %.1f" % [metric, value, limits.max])
            performance_threshold_exceeded.emit(metric, value)

func export_report() -> String:
    var report = "=== Performance Report ===\n"
    report += "Timestamp: %s\n\n" % Time.get_datetime_string_from_system()
    
    report += "Current Metrics:\n"
    for metric in current_metrics:
        report += "  %s: %.2f\n" % [metric, current_metrics[metric]]
    
    if alerts.size() > 0:
        report += "\nAlerts:\n"
        for alert in alerts:
            report += "  ⚠️ %s\n" % alert
    
    report += "\nRecommendations:\n"
    report += _generate_recommendations()
    
    return report

func _generate_recommendations() -> String:
    var recommendations = []
    
    if current_metrics.collision_pairs > 5000:
        recommendations.append("- Reduce enemy spawn rate or increase spawn spacing")
        recommendations.append("- Check collision layer configuration")
        recommendations.append("- Implement spatial partitioning")
    
    if current_metrics.fps < 55:
        recommendations.append("- Reduce shader quality")
        recommendations.append("- Lower enemy count")
        recommendations.append("- Optimize LOD distances")
    
    if current_metrics.memory_mb > 250:
        recommendations.append("- Check for memory leaks")
        recommendations.append("- Reduce texture sizes")
        recommendations.append("- Optimize pool sizes")
    
    return "\n".join(recommendations) if recommendations.size() > 0 else "System performing within limits"
```

---

## 🚀 Implementation Roadmap voor TheCaves

### Week 1: Foundation
- [x] Complete debugging guide documentatie
- [ ] Implement Logger.gd autoload
- [ ] Setup PerformanceMonitor.gd
- [ ] Add basic DebugHUD
- [ ] Configure collision layers properly

### Week 2: Performance Tools
- [ ] Implement LOD debugging system
- [ ] Add collision pair analyzer
- [ ] Setup object pool analytics
- [ ] Create shader profiler
- [ ] Add memory leak detector

### Week 3: Advanced Features
- [ ] MCP debug server implementation
- [ ] GdUnit4 test suite setup
- [ ] Automated performance tests
- [ ] Visual debugging tools
- [ ] Emergency optimizer

### Week 4: Polish & Integration
- [ ] Complete debug console
- [ ] AI-powered analysis
- [ ] Performance dashboard
- [ ] Export tools
- [ ] Documentation finalization

---

## 💡 Quick Tips & Best Practices

### Daily Debug Routine
1. **Start**: Check baseline FPS and collision pairs
2. **During Dev**: Monitor performance dashboard
3. **After Features**: Run performance tests
4. **Before Commit**: Check for memory leaks
5. **End**: Export performance report

### Red Flags to Watch
- Collision pairs > 8,000 = **CRITICAL**
- FPS < 45 = **Unplayable**
- Memory growth > 10MB/minute = **Leak**
- Frame time > 25ms = **Stuttering**
- Draw calls > 2,000 = **GPU bottleneck**

### Emergency Checklist
```gdscript
# When performance tanks:
1. Check collision pairs FIRST
2. Count active enemies/projectiles
3. Profile shaders
4. Check memory usage
5. Analyze LOD distribution
6. Review pool exhaustion
7. Enable emergency mode if needed
```

---

*🎮 Remember: In roguelites, performance IS gameplay. Debug early, debug often, and always monitor collision pairs!*

**Last Updated**: Godot 4.3 - December 2024
**For**: TheCaves Roguelite Project
**Target**: 60 FPS with 150+ enemies