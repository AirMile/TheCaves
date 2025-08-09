# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**TheCaves** is a top-down roguelite game inspired by Brotato, Vampire Survivors, and Halls of Torment. The game features a unique neon cave painting aesthetic and is built with Godot 4.3. The primary performance target is maintaining 60 FPS with 100+ enemies on screen simultaneously.

**Team**: Miles (Code Lead) & Jade (Art Lead)  
**Engine**: Godot 4.3  
**Language**: GDScript with static typing  
**Target**: 60 FPS @ 1080p with 100-150 enemies  

## Development Commands

Since this is a Godot project, development is primarily done through the Godot editor:

```bash
# Open project in Godot
# 1. Launch Godot 4.3+
# 2. Click "Import"
# 3. Navigate to project.godot file
# 4. Click "Import & Edit"

# Git workflow (from GIT_STRATEGY.md)
git checkout -b feature/[name]
git commit -m "type: description"  # feat/fix/perf/art
git push origin feature/[name]

# Performance monitoring (in-game)
# F3 - Toggle debug panel (FPS, entities, collision pairs)
```

**No build commands** - Godot handles compilation automatically  
**No test framework** - Early-stage game project without formal testing  
**No linting tools** - Godot editor provides built-in script validation

## Claude Development Requirements

**MANDATORY: Always use Context7 for Godot documentation and API reference**

When working with any Godot-related code, patterns, or API calls:

1. **Always use Context7 first** - Before implementing any Godot functionality, use the Context7 tool to get up-to-date documentation from official Godot sources
2. **Library ID**: Use `/godotengine/godot-docs` for comprehensive API documentation and best practices
3. **Specific searches**: Focus Context7 searches on the specific functionality (e.g., "signals", "autoload", "performance", "object pooling")
4. **Verify patterns**: Use Context7 to confirm syntax, methods, and implementation patterns before coding
5. **Error resolution**: When encountering Godot errors, use Context7 to understand the correct API usage

**Context7 Godot Libraries Priority Order:**
1. `/godotengine/godot-docs` - Official documentation (13573+ snippets, Trust: 9.9)
2. `/godotengine/godot` - Engine source for advanced patterns (134 snippets, Trust: 9.9)
3. `/godotengine/godot-demo-projects` - Official examples (34 snippets, Trust: 9.9)
4. `/godotengine/godot-cpp` - C++ bindings reference (27 snippets, Trust: 9.9)

**Example Context7 Usage:**
```
# For signal implementation issues:
mcp__context7__get-library-docs with /godotengine/godot-docs, topic: "signals emit connect"

# For performance optimization:
mcp__context7__get-library-docs with /godotengine/godot-docs, topic: "performance object pooling"

# For autoload problems:
mcp__context7__get-library-docs with /godotengine/godot-docs, topic: "autoload singleton"
```

This ensures all implementations follow official Godot patterns and avoid deprecated or incorrect API usage.

## Godot MCP Integration

**AVAILABLE: Godot-specific MCP server for direct engine interaction**

In addition to Context7, this project now includes a dedicated Godot MCP server for direct engine integration:

1. **Godot MCP Tools** - Direct access to Godot Engine operations via MCP protocol
2. **Engine Interaction** - Can interact with running Godot instances and project files  
3. **Project-Specific Operations** - Tools optimized for Godot game development workflow

**Usage Priority:**
1. **Godot MCP** - For direct engine operations, project manipulation, scene editing
2. **Context7** - For API documentation, best practices, error resolution, pattern verification

### Critical MCP Usage Requirements

**🚨 IMPORTANT: Always use relative path "." for projectPath parameter**

The Godot MCP server in WSL2 environments ONLY works with relative paths from the current working directory:

```bash
# ✅ CORRECT - Use relative path
mcp__godot-mcp__run_project with projectPath: "."
mcp__godot-mcp__create_scene with projectPath: "."
mcp__godot-mcp__add_node with projectPath: "."

# ❌ WRONG - Absolute paths fail in WSL2
mcp__godot-mcp__run_project with projectPath: "/mnt/c/gameProjects/TheCaves"
mcp__godot-mcp__create_scene with projectPath: "C:/gameProjects/TheCaves"
```

### Working MCP Features

**✅ Fully Functional:**
- `get_godot_version` - Get installed Godot version
- `get_project_info` - Project structure analysis 
- `launch_editor` - Open Godot editor
- `list_projects` - Find Godot projects in directories
- `run_project` - Execute project in debug mode
- `get_debug_output` - Capture console output and errors
- `add_node` - Add nodes to existing scenes with properties
- `get_uid` - Get file UIDs (Godot 4.4+)
- `stop_project` - Stop running project

**⚠️ Partially Working:**
- `create_scene` - Creates scenes but files may not persist
- `save_scene` - May not always write to disk

### MCP Workflow Examples

**Debug Project Errors:**
```bash
# 1. Run project to identify issues
mcp__godot-mcp__run_project with projectPath: "."

# 2. Get debug output with full error details
mcp__godot-mcp__get_debug_output

# 3. Stop project when done
mcp__godot-mcp__stop_project
```

**Scene Editing:**
```bash
# 1. Add UI element to existing scene
mcp__godot-mcp__add_node with:
  projectPath: "."
  scenePath: "scenes/Player.tscn"
  nodeType: "Label"
  nodeName: "HealthLabel"
  properties: {"text": "Health: 100", "position": [10, 10]}

# 2. Load sprite texture
mcp__godot-mcp__load_sprite with:
  projectPath: "."
  scenePath: "scenes/Enemy.tscn"
  nodePath: "root/Sprite2D"
  texturePath: "assets/sprites/enemy.png"
```

**Project Analysis:**
```bash
# Get detailed project structure
mcp__godot-mcp__get_project_info with projectPath: "."

# Find all Godot projects in directory tree
mcp__godot-mcp__list_projects with directory: "/path/to/search" recursive: true
```

The Godot MCP provides tools that complement Context7's documentation by enabling direct interaction with the Godot Engine and project files.  

## Architecture Overview

### Performance-First Design
The entire architecture is designed around handling 100+ enemies at 60 FPS:

1. **Object Pooling System** - All dynamic objects (enemies, projectiles, particles) must be pooled
2. **Component-Based Architecture** - Composition over inheritance for upgrades
3. **LOD (Level of Detail) System** - Distance-based performance scaling
4. **Event Bus Pattern** - Decoupled communication via signals

### Planned Project Structure
```
TheCaves/
├── autoloads/              # Singleton systems (Godot autoload)
│   ├── EnemyPool.gd       # Pool 150 enemies (50% over target)
│   ├── ProjectileManager.gd # Pool 500 projectiles
│   ├── InputManager.gd    # Unified input (KB+Controller)
│   ├── EventBus.gd        # Global event system
│   └── AudioManager.gd    # Audio pooling (20 players)
├── components/            # Reusable components
│   ├── HealthComponent.gd
│   ├── MovementComponent.gd
│   └── AIComponent.gd
├── enemies/               # Enemy scripts with LOD
├── scenes/                # Godot scene files (.tscn)
├── scripts/               # GDScript files
├── assets/                # Game assets
│   ├── sprites/          # PNG textures (use atlases)
│   ├── audio/            # OGG Vorbis files
│   └── shaders/          # Visual shaders
└── resources/             # Godot resources (.tres)
```

## Critical Performance Patterns

### Object Pooling Implementation
```gdscript
# EnemyPool.gd (Autoload)
extends Node

const POOL_SIZES = {
    "swarm": 80,    # Small, numerous
    "ranged": 40,   # Medium count  
    "tank": 20,     # Few but heavy
    "boss": 2       # Rare spawns
}

var enemy_pools: Dictionary = {}

func _ready():
    for enemy_type in POOL_SIZES:
        enemy_pools[enemy_type] = []
        var scene = load("res://enemies/Enemy%s.tscn" % enemy_type.capitalize())
        
        for i in POOL_SIZES[enemy_type]:
            var enemy = scene.instantiate()
            enemy.set_process(false)
            enemy.set_physics_process(false)
            enemy.visible = false
            add_child(enemy)
            enemy_pools[enemy_type].append(enemy)

func get_enemy(type: String) -> Enemy:
    var pool = enemy_pools.get(type, [])
    for enemy in pool:
        if not enemy.active:
            enemy.activate()
            return enemy
    return pool[0]  # Force reuse if pool exhausted
```

### LOD System Implementation
```gdscript
# Enemy.gd - LOD-aware enemy
enum DetailLevel { HIGH, MEDIUM, LOW, MINIMAL }

var current_lod: DetailLevel = DetailLevel.HIGH
@onready var player_ref: Node2D = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float):
    update_lod()
    
    match current_lod:
        DetailLevel.HIGH:      # 0-300px
            full_ai_update(delta)
            update_animation()
            process_abilities()
        DetailLevel.MEDIUM:    # 300-600px  
            simple_ai_update(delta)
            update_animation()
        DetailLevel.LOW:       # 600-900px
            basic_movement(delta)
        DetailLevel.MINIMAL:   # 900px+
            # Position only
            pass

func update_lod():
    var distance_sq = global_position.distance_squared_to(player_ref.global_position)
    
    if distance_sq < 90000:      # 300px
        current_lod = DetailLevel.HIGH
    elif distance_sq < 360000:   # 600px
        current_lod = DetailLevel.MEDIUM  
    elif distance_sq < 810000:   # 900px
        current_lod = DetailLevel.LOW
    else:
        current_lod = DetailLevel.MINIMAL
```

### Component Architecture
```gdscript
# Use composition for flexible upgrades
@onready var health: HealthComponent = $HealthComponent
@onready var movement: MovementComponent = $MovementComponent
@onready var ai: AIComponent = $AIComponent

# HealthComponent.gd
extends Node
class_name HealthComponent

signal died
signal health_changed(new_health: int)

@export var max_health: int = 100
var current_health: int

func _ready():
    current_health = max_health

func take_damage(amount: int):
    current_health = max(0, current_health - amount)
    health_changed.emit(current_health)
    if current_health <= 0:
        died.emit()
```

### Collision Layer Setup
```gdscript
# Project Settings collision layers:
# Layer 1: Walls (static environment)
# Layer 2: Player
# Layer 3: Enemies (NO inter-enemy collision!)
# Layer 4: Player Projectiles  
# Layer 5: Enemy Projectiles
# Layer 6: Pickups

# Enemy collision setup
func _ready():
    collision_layer = 3  # Enemy layer
    collision_mask = 1 | 2 | 4  # Walls, Player, Player Projectiles
    # Enemies do NOT collide with each other for performance
```

## Critical Performance Requirements

### Performance Targets
- **FPS**: 60 stable (55 absolute minimum)
- **Enemies**: 100-150 simultaneous on screen
- **Projectiles**: 200-300 active
- **Draw Calls**: < 100 per frame
- **Physics Bodies**: < 200 active
- **Memory**: < 500MB RAM
- **Collision Pairs**: < 5,000 (monitor with Performance.PHYSICS_2D_COLLISION_PAIRS)

### Frame Budget (16.67ms @ 60fps)
```
Physics:     4-5ms  (movement, collision)
AI:          3-4ms  (enemy decisions)  
Rendering:   5-6ms  (sprites, effects)
Audio:       1ms    (sfx mixing)
UI:          1-2ms  (HUD updates)
Buffer:      2ms    (spike tolerance)
```

## Development Guidelines

### Code Standards
- **Static typing required**: `var health: int = 100`
- **Cache node references**: `@onready var player = get_node("/Player")`
- **Use distance_squared_to()** for distance comparisons (avoid sqrt)
- **Component composition** over inheritance
- **Pool all spawnable objects** - never `instantiate()` during gameplay
- **EventBus for decoupled communication**
- **Functions < 20 lines**

### Performance Anti-Patterns (AVOID)
```gdscript
# ❌ Creating objects in loops
for i in 100:
    var bullet = bullet_scene.instantiate()

# ❌ String concatenation in _process
func _process(delta):
    label.text = "Score: " + str(score)

# ❌ Finding nodes every frame  
func _process(delta):
    var player = get_node("/Player")

# ❌ Inter-enemy collision
collision_mask = 1 | 2 | 3  # DON'T include enemy layer
```

### Performance Best Practices
```gdscript
# ✅ Object pooling
var bullet = ProjectileManager.get_bullet()

# ✅ Cached string formatting
@onready var score_format = "Score: %d"
label.text = score_format % score

# ✅ Cached references
@onready var player: Node2D = get_node("/Player")

# ✅ Distance squared comparisons
if position.distance_squared_to(target) < range * range:
    # In range
```

### Staggered Updates for Performance
```gdscript
# Don't update all enemies every frame
func _physics_process(delta):
    var frame = Engine.get_physics_frames()
    var update_group = frame % 4  # Update 1/4 each frame
    
    for i in range(enemies.size()):
        if i % 4 == update_group:
            enemies[i].update_ai(delta * 4)  # Compensate for 1/4 rate
```

## Project Settings Optimization

### Essential Project Settings
```ini
# project.godot optimizations
[rendering]
textures/canvas_textures/default_texture_filter=1  # Pixel perfect
driver/threads/thread_model=2  # Multi-threaded

[physics] 
2d/default_gravity=0.0  # Top-down game
common/physics_ticks_per_second=60  # Can reduce to 30 if needed
common/max_physics_steps_per_frame=8

[layer_names]
2d_physics/layer_1="Walls"
2d_physics/layer_2="Player" 
2d_physics/layer_3="Enemies"
2d_physics/layer_4="PlayerProjectiles"
2d_physics/layer_5="EnemyProjectiles"  
2d_physics/layer_6="Pickups"

[autoload]
EventBus="*res://scripts/autoload/EventBus.gd"
InputManager="*res://scripts/autoload/InputManager.gd"
EnemyPool="*res://scripts/autoload/EnemyPool.gd"
ProjectileManager="*res://scripts/autoload/ProjectileManager.gd"
AudioManager="*res://scripts/autoload/AudioManager.gd"
```

## Debug and Profiling Tools

### Performance Monitoring (F3 Debug Panel)
```gdscript
# DebugPanel.gd - Toggle with F3
extends Control

@onready var fps_label = $VBox/FPS
@onready var enemies_label = $VBox/Enemies  
@onready var projectiles_label = $VBox/Projectiles
@onready var collision_pairs_label = $VBox/CollisionPairs

func _ready():
    visible = false

func _process(_delta):
    if Input.is_action_just_pressed("debug_toggle"):  # F3
        visible = !visible
    
    if visible:
        fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
        enemies_label.text = "Enemies: %d" % get_tree().get_nodes_in_group("enemies").size()
        projectiles_label.text = "Projectiles: %d" % get_tree().get_nodes_in_group("projectiles").size()
        
        var pairs = Performance.get_monitor(Performance.PHYSICS_2D_COLLISION_PAIRS)
        collision_pairs_label.text = "Collision Pairs: %d" % pairs
        
        if pairs > 5000:
            collision_pairs_label.modulate = Color.RED
```

## Documentation References

Complete project documentation is in `Notes/` (Obsidian vault):
- `Notes/06_Development_Guides/Godot_Best_Practices.md` - Complete implementation patterns
- `Notes/06_Development_Guides/Performance_Guidelines.md` - Detailed optimization strategies
- `Notes/PROJECT_INSTRUCTIONS.md` - Current implementation focus
- `Notes/01_Design/Game_Design_Document.md` - Core game mechanics

**Always test with 150 enemies + 200 projectiles before considering any feature complete.**

## Git Workflow

From `GIT_STRATEGY.md`:
```bash
# Feature branch workflow
git checkout -b feature/enemy-spawning
git commit -m "feat(enemies): add wave spawning system"
git commit -m "fix(player): resolve dash collision bug"  
git commit -m "perf(pooling): optimize enemy pool allocation"
git push origin feature/enemy-spawning
```

## Architecture Reminders

1. **Pool Everything** - Enemies, projectiles, particles, damage numbers
2. **Component-Based** - Flexible upgrade system through composition  
3. **Event-Driven** - EventBus for decoupled system communication
4. **LOD-Aware** - All systems consider distance-based optimization
5. **Static Typing** - Performance and maintainability
6. **Performance First** - 60 FPS with 100+ enemies is a core requirement, not optional