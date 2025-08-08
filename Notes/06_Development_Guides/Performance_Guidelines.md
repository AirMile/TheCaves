# ⚡ Performance Guidelines - 100+ Enemies

## 🎯 Performance Targets

### Minimum Requirements
- **FPS**: 60 stable (55 absolute minimum)
- **Enemies**: 100-150 simultaneous
- **Projectiles**: 200-300 active
- **Particles**: 50-100 systems
- **Draw Calls**: < 100
- **Memory**: < 500MB RAM

### Test Scenarios
1. **Stress Test**: 150 enemies + 200 projectiles
2. **Particle Storm**: All abilities active
3. **Wave Clear**: 100 enemies dying simultaneously
4. **Boss Fight**: Large enemies + adds

## 🏊 Object Pooling Strategy

### Enemy Pool Sizes
```gdscript
const POOL_SIZES = {
    "swarm": 80,    # Small, numerous
    "ranged": 40,   # Medium count
    "tank": 20,     # Few but heavy
    "boss": 2,      # Rare spawns
    "elite": 10     # Mini-bosses
}
```

### Projectile Pooling
```gdscript
const PROJECTILE_POOLS = {
    "player_bullet": 100,
    "enemy_bullet": 200,
    "ability_projectile": 50,
    "explosion": 30
}
```

## 🎮 LOD (Level of Detail) System

### Distance Thresholds
```
0-300px:    FULL (alle features)
300-600px:  HIGH (geen shadows)
600-900px:  MEDIUM (simple AI, geen particles)
900-1200px: LOW (alleen movement)
1200px+:    MINIMAL (alleen position updates)
```

### Per-LOD Features
```gdscript
# FULL - Alles aan
- Complex AI pathfinding
- All animations
- Particle effects
- Shadow rendering
- Audio effects
- Collision checks

# HIGH - Minor reductions
- Simple pathfinding
- All animations
- Limited particles
- No shadows
- Audio effects
- Collision checks

# MEDIUM - Balanced
- Direct movement
- Key animations only
- No particles
- No shadows
- Important audio only
- Collision checks

# LOW - Basics
- Linear movement
- No animations
- No particles
- No shadows
- No audio
- Simple collision

# MINIMAL - Position only
- Position interpolation
- No animations
- No effects
- No collision
```

## 🖼️ Sprite Optimization

### Texture Atlases
```
enemies_atlas.png (512x512)
├── swarm_enemy (32x32)
├── ranged_enemy (48x48)
├── tank_enemy (64x64)
└── Shared parts for mixing

projectiles_atlas.png (256x256)
├── bullets (8x8)
├── missiles (16x16)
└── explosions (32x32)
```

### Sprite Guidelines
- Max texture size: 512x512
- Use power of 2 dimensions
- Share textures where possible
- Batch similar sprites
- Compress: WebP for backgrounds

## 🔄 Update Optimization

### Staggered Updates
```gdscript
# Niet alle enemies tegelijk updaten
func _physics_process(delta):
    var frame = Engine.get_physics_frames()
    var update_group = frame % 4
    
    for i in range(enemies.size()):
        if i % 4 == update_group:
            enemies[i].update_ai(delta * 4)
```

### Priority System
```gdscript
enum Priority { CRITICAL, HIGH, NORMAL, LOW }

# Update frequency based on priority
var update_intervals = {
    Priority.CRITICAL: 1,   # Every frame
    Priority.HIGH: 2,       # Every 2 frames
    Priority.NORMAL: 4,     # Every 4 frames
    Priority.LOW: 8         # Every 8 frames
}
```

## 💥 Particle Optimization

### Particle Limits
```gdscript
const MAX_PARTICLES = {
    "hit_effect": 5,
    "explosion": 20,
    "trail": 10,
    "death": 15,
    "ability": 30
}

# GPU particles voor mass effects
# CPU particles voor precise control
```

### Effect Pooling
```gdscript
# Reuse particle systems
var explosion_pool: Array[GPUParticles2D] = []

func create_explosion(pos: Vector2):
    var explosion = get_from_pool(explosion_pool)
    explosion.global_position = pos
    explosion.restart()
    explosion.emitting = true
```

## 🎯 Collision Optimization

### Layer Setup
```
Layer 1: Walls (static)
Layer 2: Player
Layer 3: Enemies (no self-collision!)
Layer 4: Player projectiles
Layer 5: Enemy projectiles
Layer 6: Pickups
```

### Spatial Partitioning
```gdscript
# Grid-based collision checking
var collision_grid = {}
const GRID_SIZE = 128

func add_to_grid(object):
    var grid_pos = (object.position / GRID_SIZE).floor()
    var key = "%d,%d" % [grid_pos.x, grid_pos.y]
    
    if not collision_grid.has(key):
        collision_grid[key] = []
    collision_grid[key].append(object)
```

## 📊 Profiling Tools

### Built-in Monitors
```gdscript
# In GameManager
func _ready():
    if OS.is_debug_build():
        var monitors = [
            Performance.TIME_FPS,
            Performance.TIME_PROCESS,
            Performance.TIME_PHYSICS_PROCESS,
            Performance.MEMORY_STATIC,
            Performance.OBJECT_COUNT,
            Performance.RENDER_DRAW_CALLS_IN_FRAME
        ]
        
        for monitor in monitors:
            print(Performance.get_monitor_name(monitor), ": ", 
                  Performance.get_monitor(monitor))
```

### Custom Profiler
```gdscript
class_name Profiler

static var timings = {}

static func start(label: String):
    timings[label] = Time.get_ticks_usec()

static func end(label: String):
    if label in timings:
        var elapsed = Time.get_ticks_usec() - timings[label]
        print("%s: %.2f ms" % [label, elapsed / 1000.0])

# Usage:
Profiler.start("enemy_update")
update_all_enemies()
Profiler.end("enemy_update")
```

## 🔥 Critical Paths

### Frame Budget (16.67ms @ 60fps)
```
Physics:     4-5ms  (movement, collision)
AI:          3-4ms  (enemy decisions)
Rendering:   5-6ms  (sprites, effects)
Audio:       1ms    (sfx mixing)
UI:          1-2ms  (HUD updates)
Buffer:      2ms    (spike tolerance)
```

### Bottleneck Priority
1. **Draw calls** - Batch everything possible
2. **Physics bodies** - Limit active bodies
3. **Particles** - GPU particles preferred
4. **AI calculations** - Stagger updates
5. **Instantiation** - Always pool

## 🛠️ Debug Commands

### Performance Toggles
```gdscript
# DevConsole.gd
var commands = {
    "fps": toggle_fps_display,
    "lod": toggle_lod_visualization,
    "collision": toggle_collision_shapes,
    "pool_stats": show_pool_statistics,
    "spawn_stress": spawn_100_enemies,
    "clear": clear_all_enemies,
    "profile": toggle_profiler
}
```

## 📈 Optimization Checklist

### Per Sprint
- [ ] Profile with 150 enemies
- [ ] Check draw call count
- [ ] Monitor memory usage
- [ ] Test on min spec
- [ ] Identify bottlenecks

### Before Feature
- [ ] Consider performance impact
- [ ] Plan pooling strategy
- [ ] Design LOD behavior
- [ ] Set performance budget

### After Implementation
- [ ] Profile before/after
- [ ] Stress test feature
- [ ] Check frame stability
- [ ] Optimize hot paths
- [ ] Document limits

## 🚫 Performance Anti-Patterns

### AVOID:
```gdscript
# ❌ Creating objects in loops
for i in 100:
    var bullet = bullet_scene.instantiate()

# ❌ String concatenation in process
func _process(delta):
    label.text = "Score: " + str(score)

# ❌ Finding nodes every frame
func _process(delta):
    var player = get_node("/root/Game/Player")

# ❌ Unnecessary signal connections
for enemy in 1000:
    enemy.died.connect(on_enemy_died)
```

### PREFER:
```gdscript
# ✅ Object pooling
var bullet = bullet_pool.get_bullet()

# ✅ Cache formatted strings
var score_format = "Score: %d"
label.text = score_format % score

# ✅ Cache node references
@onready var player = get_node("/root/Game/Player")

# ✅ Single manager for events
EventBus.enemy_died.connect(on_enemy_died)
```

## 🎮 Platform Specific

### PC (Primary Target)
- Target: 1080p @ 60fps
- Min spec: GTX 1050 / RX 560
- RAM: 4GB minimum
- CPU: Dual core 2.5GHz+

### Steam Deck (Future)
- Target: 800p @ 60fps
- Reduce particles by 50%
- Lower shadow quality
- Optimize for battery

---

*⚡ Remember: Profile first, optimize second, assume nothing!*