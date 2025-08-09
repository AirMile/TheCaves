# 🎮 Brotato Clone Foundation - Complete Implementation Plan

## Overview
Dit document bevat het complete implementatieplan voor een Brotato-clone foundation in TheCaves project. Gebruik dit document als context om morgen verder te werken met meerdere agents.

## Branch Info
- **Branch naam**: `feature/brotato-foundation`
- **Status**: Branch is aangemaakt, directory structuur is klaar

## ✅ Completed Tasks
1. ✅ Created feature/brotato-foundation branch
2. ✅ Created complete directory structure

## 📋 Todo List Status

### Phase 1: Core Systems Setup (Autoloads) - HIGH PRIORITY
- [ ] **EventBus System** (`scripts/autoload/EventBus.gd`)
- [ ] **InputManager** (`scripts/autoload/InputManager.gd`)  
- [ ] **EnemyPool** (`scripts/autoload/EnemyPool.gd`)
- [ ] **ProjectileManager** (`scripts/autoload/ProjectileManager.gd`)
- [ ] **AudioManager** (`scripts/autoload/AudioManager.gd`)
- [ ] **GameManager** (`scripts/autoload/GameManager.gd`)

### Phase 2: Component Architecture - HIGH PRIORITY
- [ ] **HealthComponent** (`components/HealthComponent.gd`)
- [ ] **MovementComponent** (`components/MovementComponent.gd`)
- [ ] **HitboxComponent** (`components/HitboxComponent.gd`)
- [ ] **HurtboxComponent** (`components/HurtboxComponent.gd`)
- [ ] **StatsComponent** (`components/StatsComponent.gd`)
- [ ] **AIComponent** (`components/AIComponent.gd`)
- [ ] **WeaponComponent** (`components/WeaponComponent.gd`)

### Phase 3: Player Implementation
- [ ] **Player Scene** (`scenes/player/Player.tscn`)
- [ ] **Player Controller** (`scripts/player/PlayerController.gd`)

### Phase 4: Enemy System
- [ ] **Base Enemy** (`scenes/enemies/BaseEnemy.tscn`)
- [ ] **SwarmEnemy** implementation
- [ ] **RangedEnemy** implementation
- [ ] **TankEnemy** implementation

### Phase 5: Wave & Spawning
- [ ] **WaveManager** (`scripts/systems/WaveManager.gd`)
- [ ] **SpawnPoint System**

### Phase 6: Weapon System
- [ ] **MeleeWeapon** (`scenes/weapons/MeleeWeapon.tscn`)
- [ ] **ProjectileWeapon** (`scenes/weapons/ProjectileWeapon.tscn`)
- [ ] **Upgrade System**

### Phase 7: UI Implementation
- [ ] **HUD** (`scenes/ui/HUD.tscn`)
- [ ] **UpgradePanel** (`scenes/ui/UpgradePanel.tscn`)
- [ ] **Debug Panel** enhancement

### Phase 8: Arena
- [ ] **TestArena** (`scenes/arenas/TestArena.tscn`)

### Phase 9: Pickups
- [ ] **ExperienceGem** (`scenes/pickups/ExperienceGem.tscn`)
- [ ] **HealthPotion** (`scenes/pickups/HealthPotion.tscn`)

## 🤖 Agent Task Allocation Strategy

Voor optimale performance met meerdere agents, kunnen taken parallel uitgevoerd worden:

### Agent 1: Core Systems Specialist
**Focus**: Autoload systems
```
Tasks:
1. EventBus.gd - Global signal system
2. InputManager.gd - Input handling
3. GameManager.gd - Game state management
```

### Agent 2: Component Architecture Specialist  
**Focus**: Reusable components
```
Tasks:
1. HealthComponent.gd
2. MovementComponent.gd
3. HitboxComponent.gd + HurtboxComponent.gd
4. StatsComponent.gd
```

### Agent 3: Enemy & AI Specialist
**Focus**: Enemy system with LOD
```
Tasks:
1. EnemyPool.gd autoload
2. BaseEnemy scene + script
3. AIComponent.gd
4. Enemy variants (Swarm, Ranged, Tank)
```

### Agent 4: Player & Weapons Specialist
**Focus**: Player mechanics and weapons
```
Tasks:
1. Player.tscn + PlayerController.gd
2. WeaponComponent.gd
3. ProjectileManager.gd autoload
4. Weapon scenes (Melee, Projectile)
```

### Agent 5: UI & Systems Specialist
**Focus**: UI and game systems
```
Tasks:
1. WaveManager.gd
2. HUD.tscn + script
3. UpgradePanel.tscn + script
4. Debug Panel enhancement
```

## 📝 Implementation Details Per Component

### EventBus.gd
```gdscript
extends Node

# Player signals
signal player_hit(damage: int)
signal player_died()
signal player_leveled_up(new_level: int)

# Enemy signals  
signal enemy_spawned(enemy: Node2D)
signal enemy_died(enemy: Node2D, position: Vector2)

# Game state signals
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal game_over()

# Pickup signals
signal pickup_collected(pickup_type: String, value: float)
signal experience_gained(amount: int)

# Upgrade signals
signal upgrade_selected(upgrade: Dictionary)
signal weapon_unlocked(weapon_type: String)
```

### InputManager.gd
```gdscript
extends Node

var movement_vector: Vector2 = Vector2.ZERO
var aim_direction: Vector2 = Vector2.ZERO
var using_controller: bool = false

func _ready():
    Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _process(_delta: float):
    update_movement()
    update_aim()
    detect_input_device()

func update_movement():
    movement_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    movement_vector = movement_vector.normalized()

func update_aim():
    if using_controller:
        var aim_x = Input.get_axis("aim_left", "aim_right")
        var aim_y = Input.get_axis("aim_up", "aim_down")
        if aim_x != 0 or aim_y != 0:
            aim_direction = Vector2(aim_x, aim_y).normalized()
    else:
        var mouse_pos = get_viewport().get_mouse_position()
        var screen_center = get_viewport().size / 2
        aim_direction = (mouse_pos - screen_center).normalized()
```

### EnemyPool.gd
```gdscript
extends Node

const POOL_SIZES = {
    "swarm": 80,
    "ranged": 40,
    "tank": 20,
    "boss": 2
}

var enemy_pools: Dictionary = {}
var enemy_scenes: Dictionary = {}

func _ready():
    preload_enemy_scenes()
    initialize_pools()

func preload_enemy_scenes():
    enemy_scenes["swarm"] = preload("res://scenes/enemies/SwarmEnemy.tscn")
    enemy_scenes["ranged"] = preload("res://scenes/enemies/RangedEnemy.tscn")
    enemy_scenes["tank"] = preload("res://scenes/enemies/TankEnemy.tscn")
    enemy_scenes["boss"] = preload("res://scenes/enemies/BossEnemy.tscn")

func initialize_pools():
    for enemy_type in POOL_SIZES:
        enemy_pools[enemy_type] = []
        var scene = enemy_scenes[enemy_type]
        
        for i in POOL_SIZES[enemy_type]:
            var enemy = scene.instantiate()
            enemy.set_process(false)
            enemy.set_physics_process(false)
            enemy.visible = false
            add_child(enemy)
            enemy_pools[enemy_type].append(enemy)

func get_enemy(type: String) -> Node2D:
    var pool = enemy_pools.get(type, [])
    for enemy in pool:
        if not enemy.active:
            enemy.activate()
            return enemy
    # Force reuse oldest if pool exhausted
    var enemy = pool[0]
    enemy.reset()
    enemy.activate()
    return enemy

func return_enemy(enemy: Node2D):
    enemy.deactivate()
```

### HealthComponent.gd
```gdscript
extends Node
class_name HealthComponent

signal died
signal health_changed(new_health: int, max_health: int)
signal damage_taken(amount: int)
signal healed(amount: int)

@export var max_health: int = 100
var current_health: int

func _ready():
    current_health = max_health

func take_damage(amount: int):
    var actual_damage = min(amount, current_health)
    current_health -= actual_damage
    damage_taken.emit(actual_damage)
    health_changed.emit(current_health, max_health)
    
    if current_health <= 0:
        died.emit()

func heal(amount: int):
    var actual_heal = min(amount, max_health - current_health)
    current_health += actual_heal
    healed.emit(actual_heal)
    health_changed.emit(current_health, max_health)

func get_health_percentage() -> float:
    return float(current_health) / float(max_health)
```

### MovementComponent.gd
```gdscript
extends Node
class_name MovementComponent

@export var base_speed: float = 200.0
@export var acceleration: float = 10.0
@export var friction: float = 10.0

var velocity: Vector2 = Vector2.ZERO
var speed_multiplier: float = 1.0

func accelerate_towards(direction: Vector2, delta: float):
    var target_velocity = direction * base_speed * speed_multiplier
    velocity = velocity.move_toward(target_velocity, acceleration * base_speed * delta)

func apply_friction(delta: float):
    velocity = velocity.move_toward(Vector2.ZERO, friction * base_speed * delta)

func move(body: CharacterBody2D):
    body.velocity = velocity
    body.move_and_slide()

func get_current_speed() -> float:
    return velocity.length()
```

## 🎯 Performance Requirements

### Critical Metrics
- **60 FPS** met 150 enemies + 200 projectiles
- **< 100 draw calls** per frame
- **< 500MB RAM** usage
- **< 5000 collision pairs**
- **Zero runtime instantiation** - alles moet gepooled zijn

### Collision Layers
```
Layer 1: Walls (static environment)
Layer 2: Player
Layer 3: Enemies (NO inter-enemy collision!)
Layer 4: Player Projectiles
Layer 5: Enemy Projectiles
Layer 6: Pickups
```

### LOD System for Enemies
```gdscript
enum DetailLevel { HIGH, MEDIUM, LOW, MINIMAL }

# Distance thresholds
# HIGH: 0-300px - Full AI, animations, abilities
# MEDIUM: 300-600px - Simple AI, animations
# LOW: 600-900px - Basic movement only
# MINIMAL: 900px+ - Position updates only
```

## 🚀 Quick Start Commands voor Morgen

```bash
# Ga naar project directory
cd /mnt/c/gameProjects/TheCaves

# Switch naar de juiste branch
git checkout feature/brotato-foundation

# Check status
git status

# Start met multiple agents voor parallel werk
# Agent 1: Core Systems
# Agent 2: Components
# Agent 3: Enemy System
# Agent 4: Player System
# Agent 5: UI Systems
```

## 📌 Belangrijke Notes

1. **Static Typing Overal**: `var health: int = 100` niet `var health = 100`
2. **Cache Node References**: Gebruik `@onready` voor alle node references
3. **Distance Squared**: Gebruik `distance_squared_to()` ipv `distance_to()`
4. **Object Pooling**: ALLES moet gepooled worden, geen `instantiate()` tijdens gameplay
5. **Component Based**: Gebruik composition over inheritance
6. **EventBus**: Alle systeem communicatie via EventBus signals
7. **Performance First**: Test constant met 150 enemies + 200 projectiles

## 🎮 Core Brotato Features to Implement

- ✅ Auto-attacking weapons
- ✅ Wave-based survival (15-20 waves)
- ✅ Upgrade selection between waves (3 choices)
- ✅ Multiple weapon types (6 slots max)
- ✅ Character stat system
- ✅ Currency/shop system
- ✅ 15-20 minute runs
- ✅ Performance for 100+ enemies
- ✅ Experience/leveling system
- ✅ Item synergies

---

**GEBRUIK DIT DOCUMENT ALS CONTEXT VOOR MORGEN**
Start met: "Ik wil verder werken aan de Brotato clone implementation met meerdere agents. Hier is het plan document: [upload dit document]"