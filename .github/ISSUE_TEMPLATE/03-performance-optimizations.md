---
name: "⚡ Performance Optimizations"
about: "Implement performance improvements to maintain 60 FPS with 150+ enemies"
title: "[PERFORMANCE] Optimize for 60 FPS with 150 enemies + 300 projectiles"
labels: performance, optimization, priority-high
assignees: ''
---

## 🎯 Performance Target
Maintain stable 60 FPS with:
- 150 concurrent enemies
- 300 active projectiles  
- < 500MB RAM usage
- < 5000 collision pairs
- < 16.67ms frame time

## 📊 Current Performance Issues

### 1. Memory Leak in WeaponComponent
**Location:** `scripts/components/WeaponComponent.gd:94-102`
```gdscript
# Current problematic code
for i in range(targets_in_range.size() - 1, -1, -1):
    var target = targets_in_range[i]
    if not is_instance_valid(target) or _is_target_dead(target):
        targets_in_range.remove_at(i)  # Array modification during iteration
```
**Impact:** Memory accumulation over time, performance degradation

### 2. Signal Emission Overhead
**Location:** `scripts/autoload/EventBus.gd`
- Heavy signal usage without connection pooling
- No signal batching for high-frequency events
- Missing connection validation

### 3. Enemy Cache Inefficiency
**Location:** `scripts/components/WeaponComponent.gd:147-150`
```gdscript
var enemies = get_tree().get_nodes_in_group("enemies")  # Called frequently
```
**Impact:** Tree traversal every 100ms per weapon

### 4. Missing LOD Implementation
- No distance-based detail reduction
- All enemies fully processed regardless of distance
- No animation LOD

## 🔧 Optimization Tasks

### Phase 1: Memory Management
```gdscript
# Improved target cleanup with object pooling
class_name TargetManager
extends RefCounted

var _active_targets: Array[WeakRef] = []
var _target_pool: Array[WeakRef] = []
const POOL_SIZE = 50

func add_target(target: Node2D) -> void:
    var weak_ref = _get_pooled_ref()
    weak_ref.reference = target
    _active_targets.append(weak_ref)

func cleanup_targets() -> void:
    for i in range(_active_targets.size() - 1, -1, -1):
        var ref = _active_targets[i]
        if not ref.get_ref():
            _active_targets.remove_at(i)
            _return_to_pool(ref)
```

### Phase 2: Signal Optimization
```gdscript
# Signal batching system
class_name SignalBatcher
extends Node

var _pending_signals: Dictionary = {}
var _batch_interval: float = 0.016  # One frame

func emit_batched(signal_name: String, args: Array) -> void:
    if not _pending_signals.has(signal_name):
        _pending_signals[signal_name] = []
    _pending_signals[signal_name].append(args)

func _process(_delta: float) -> void:
    for signal_name in _pending_signals:
        var batched_args = _pending_signals[signal_name]
        EventBus.emit_signal(signal_name + "_batch", batched_args)
    _pending_signals.clear()
```

### Phase 3: LOD System Implementation
```gdscript
# Distance-based LOD for enemies
extends CharacterBody2D
class_name LODEnemy

enum LODLevel { HIGH, MEDIUM, LOW, CULLED }

var current_lod: LODLevel = LODLevel.HIGH
var player_ref: Node2D

const LOD_DISTANCES = {
    LODLevel.HIGH: 100.0,
    LODLevel.MEDIUM: 200.0,
    LODLevel.LOW: 400.0,
    LODLevel.CULLED: 600.0
}

func update_lod() -> void:
    if not player_ref:
        return
    
    var dist_squared = global_position.distance_squared_to(player_ref.global_position)
    
    # Determine LOD level
    if dist_squared < LOD_DISTANCES[LODLevel.HIGH] * LOD_DISTANCES[LODLevel.HIGH]:
        set_lod_level(LODLevel.HIGH)
    elif dist_squared < LOD_DISTANCES[LODLevel.MEDIUM] * LOD_DISTANCES[LODLevel.MEDIUM]:
        set_lod_level(LODLevel.MEDIUM)
    elif dist_squared < LOD_DISTANCES[LODLevel.LOW] * LOD_DISTANCES[LODLevel.LOW]:
        set_lod_level(LODLevel.LOW)
    else:
        set_lod_level(LODLevel.CULLED)

func set_lod_level(level: LODLevel) -> void:
    if current_lod == level:
        return
    
    current_lod = level
    
    match level:
        LODLevel.HIGH:
            set_physics_process(true)
            set_process(true)
            $Sprite2D.visible = true
            $AnimationPlayer.active = true
        LODLevel.MEDIUM:
            set_physics_process(true)
            set_process(false)
            $Sprite2D.visible = true
            $AnimationPlayer.active = false
        LODLevel.LOW:
            set_physics_process(false)
            set_process(false)
            $Sprite2D.visible = true
            # Simple position interpolation only
        LODLevel.CULLED:
            set_physics_process(false)
            set_process(false)
            $Sprite2D.visible = false
```

### Phase 4: Collision Optimization
```gdscript
# Spatial hash for broad phase collision
class_name SpatialHash
extends RefCounted

var cell_size: float = 50.0
var cells: Dictionary = {}

func add_object(obj: Node2D, pos: Vector2) -> void:
    var cell = _get_cell_coord(pos)
    if not cells.has(cell):
        cells[cell] = []
    cells[cell].append(obj)

func get_nearby_objects(pos: Vector2, radius: float) -> Array:
    var results = []
    var min_cell = _get_cell_coord(pos - Vector2(radius, radius))
    var max_cell = _get_cell_coord(pos + Vector2(radius, radius))
    
    for x in range(min_cell.x, max_cell.x + 1):
        for y in range(min_cell.y, max_cell.y + 1):
            var cell = Vector2i(x, y)
            if cells.has(cell):
                results.append_array(cells[cell])
    
    return results

func _get_cell_coord(pos: Vector2) -> Vector2i:
    return Vector2i(int(pos.x / cell_size), int(pos.y / cell_size))
```

### Phase 5: Projectile Optimization
```gdscript
# Projectile batching for rendering
@tool
extends MultiMeshInstance2D
class_name ProjectileBatcher

var projectile_pool: Array[Dictionary] = []
var active_count: int = 0
const MAX_PROJECTILES = 500

func _ready():
    multimesh = MultiMesh.new()
    multimesh.mesh = QuadMesh.new()
    multimesh.transform_format = MultiMesh.TRANSFORM_2D
    multimesh.instance_count = MAX_PROJECTILES
    
    # Pre-allocate pool
    for i in MAX_PROJECTILES:
        projectile_pool.append({
            "active": false,
            "position": Vector2.ZERO,
            "velocity": Vector2.ZERO,
            "lifetime": 0.0
        })

func spawn_projectile(pos: Vector2, vel: Vector2) -> int:
    for i in MAX_PROJECTILES:
        if not projectile_pool[i].active:
            projectile_pool[i].active = true
            projectile_pool[i].position = pos
            projectile_pool[i].velocity = vel
            projectile_pool[i].lifetime = 5.0
            active_count += 1
            return i
    return -1  # Pool exhausted

func _process(delta: float):
    for i in MAX_PROJECTILES:
        if projectile_pool[i].active:
            var proj = projectile_pool[i]
            proj.position += proj.velocity * delta
            proj.lifetime -= delta
            
            if proj.lifetime <= 0:
                proj.active = false
                active_count -= 1
            
            # Update multimesh transform
            var transform = Transform2D()
            transform.origin = proj.position
            multimesh.set_instance_transform_2d(i, transform)
```

## 📈 Optimization Metrics

### Before Optimization
```
FPS: 45-50 (unstable)
Enemies: 150
Projectiles: 300
Collision Pairs: 6000-8000
Memory: 550MB
Frame Time: 20-22ms
```

### Target After Optimization
```
FPS: 60 (stable)
Enemies: 150
Projectiles: 300
Collision Pairs: < 5000
Memory: < 450MB
Frame Time: < 16.67ms
```

## ✅ Acceptance Criteria
- [ ] Stable 60 FPS with 150 enemies + 300 projectiles
- [ ] Memory usage below 500MB
- [ ] Collision pairs below 5000
- [ ] Frame time consistently below 16.67ms
- [ ] No memory leaks after 10 minutes of gameplay
- [ ] LOD system reduces processing for distant enemies

## 🧪 Performance Test Scene
```gdscript
extends Node2D

@export var spawn_enemies: int = 150
@export var spawn_projectiles: int = 300
@export var test_duration: float = 60.0

var performance_log: Array = []

func _ready():
    # Spawn test entities
    for i in spawn_enemies:
        var enemy = EnemyPool.get_enemy("swarm")
        enemy.global_position = Vector2(randf() * 1920, randf() * 1080)
    
    for i in spawn_projectiles:
        ProjectileManager.spawn_projectile(
            Vector2(randf() * 1920, randf() * 1080),
            Vector2.RIGHT.rotated(randf() * TAU)
        )
    
    # Start monitoring
    var timer = Timer.new()
    timer.wait_time = 1.0
    timer.timeout.connect(_log_performance)
    add_child(timer)
    timer.start()

func _log_performance():
    var entry = {
        "fps": Engine.get_frames_per_second(),
        "frame_time": Performance.get_monitor(Performance.TIME_PROCESS),
        "collision_pairs": Performance.get_monitor(Performance.PHYSICS_2D_COLLISION_PAIRS),
        "memory_mb": Performance.get_monitor(Performance.MEMORY_STATIC) / 1024.0 / 1024.0,
        "enemies": get_tree().get_nodes_in_group("enemies").size(),
        "projectiles": get_tree().get_nodes_in_group("projectiles").size()
    }
    performance_log.append(entry)
    
    # Check targets
    if entry.fps < 60:
        push_warning("FPS below target: %d" % entry.fps)
    if entry.collision_pairs > 5000:
        push_warning("Collision pairs above limit: %d" % entry.collision_pairs)
```

## 🔍 Profiling Tools
- Godot built-in profiler
- External: RenderDoc for GPU profiling
- Custom performance overlay (DebugPanel)
- Automated performance regression tests

## 📝 Documentation Required
- [ ] LOD system usage guide
- [ ] Performance best practices
- [ ] Profiling workflow
- [ ] Optimization checklist

## 🔗 Related Issues
- Depends on: #1 (Critical Fixes), #2 (Resource System)
- Related to: Memory management, Physics optimization
- Blocks: Content scaling, Enemy variety

## 💡 Future Optimizations
- GPU instancing for enemies/projectiles
- Texture atlasing
- Audio pool optimization
- Network optimization for multiplayer
- Save/load optimization