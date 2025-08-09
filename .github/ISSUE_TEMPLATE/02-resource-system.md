---
name: "📦 Resource System Implementation"
about: "Implement missing resource classes and scene integration"
title: "[FEATURE] Implement Resource Classes and Scene Integration"
labels: enhancement, architecture, priority-high
assignees: ''
---

## 📋 Problem Statement
The RefactoredArena system expects several Resource classes that don't exist yet. These resources are being created programmatically in `_create_resources()` but should be proper Godot Resource classes for maintainability and the editor workflow.

## 🎯 Goal
Create a robust resource system that:
- Enables data-driven game configuration
- Supports editor-based tweaking
- Maintains type safety with static typing
- Follows Godot best practices for resources

## 📦 Required Resource Classes

### 1. GameConfiguration.gd
```gdscript
@tool
extends Resource
class_name GameConfiguration

@export_group("Game Settings")
@export var config_name: String = "Default Configuration"
@export var version: String = "1.0.0"

@export_group("Player Settings")
@export var player_starting_health: int = 100
@export var player_starting_speed: float = 200.0
@export var player_starting_damage: int = 10

@export_group("Arena Settings")
@export var arena_size: Vector2 = Vector2(800, 600)
@export var max_enemies: int = 150
@export var target_fps: int = 60

@export_group("Performance")
@export var max_collision_pairs: int = 5000
@export var memory_limit_mb: float = 500.0
@export var lod_distances: Array[float] = [50.0, 100.0, 200.0]

func validate() -> bool:
    if player_starting_health <= 0:
        push_error("Player starting health must be positive")
        return false
    if max_enemies > 150:
        push_warning("Max enemies > 150 may impact 60 FPS target")
    return true
```

### 2. EnemyData.gd
```gdscript
@tool
extends Resource
class_name EnemyData

@export var enemy_id: String = "enemy"
@export var display_name: String = "Enemy"
@export var scene_path: String = ""  # Path to enemy scene

@export_group("Stats")
@export var max_health: int = 50
@export var base_speed: float = 100.0
@export var damage: int = 10
@export var experience_value: int = 10

@export_group("Visuals")
@export var sprite_texture: Texture2D
@export var sprite_color: Color = Color.WHITE
@export var collision_size: Vector2 = Vector2(20, 20)

@export_group("AI Settings")
@export_enum("chase_player", "ranged_attacker", "patrol", "ambush") var ai_type: String = "chase_player"
@export var detection_range: float = 150.0
@export var attack_range: float = 30.0
@export var attack_cooldown: float = 1.0

@export_group("Performance")
@export var use_lod: bool = true
@export var shadow_enabled: bool = false
@export var max_concurrent: int = 50
```

### 3. WaveConfiguration.gd
```gdscript
@tool
extends Resource
class_name WaveConfiguration

@export var wave_id: String = "wave_1"
@export var wave_name: String = "Wave 1"
@export_multiline var description: String = ""

@export_group("Timing")
@export var wave_duration: float = 60.0
@export var spawn_interval: float = 2.0
@export var spawn_interval_variance: float = 0.5
@export var warmup_time: float = 3.0

@export_group("Enemy Budget")
@export var max_concurrent_enemies: int = 20
@export var total_enemy_budget: int = 50
@export var difficulty_multiplier: float = 1.0

@export_group("Spawn Configuration")
@export var enemy_spawn_configs: Array[EnemySpawnConfig] = []
@export var spawn_patterns: Array[String] = ["random", "circle", "line"]

@export_group("Rewards")
@export var completion_experience: int = 500
@export var completion_gold: int = 100

func get_spawn_interval() -> float:
    return spawn_interval + randf_range(-spawn_interval_variance, spawn_interval_variance)

func calculate_enemy_count(enemy_type: String) -> int:
    var count = 0
    for config in enemy_spawn_configs:
        if config.enemy_data and config.enemy_data.enemy_id == enemy_type:
            count += config.max_spawn_count
    return int(count * difficulty_multiplier)
```

### 4. EnemySpawnConfig.gd
```gdscript
@tool
extends Resource
class_name EnemySpawnConfig

@export var enemy_data: EnemyData
@export var spawn_weight: float = 1.0
@export var max_concurrent: int = 5
@export var max_spawn_count: int = 10

@export_group("Spawn Rules")
@export var min_spawn_time: float = 0.0  # Don't spawn before this time
@export var max_spawn_time: float = -1.0  # Stop spawning after (-1 = no limit)
@export var spawn_distance_from_player: Vector2 = Vector2(100, 200)  # Min/max distance

@export_group("Modifiers")
@export var health_multiplier: float = 1.0
@export var speed_multiplier: float = 1.0
@export var damage_multiplier: float = 1.0

func can_spawn_at_time(current_time: float) -> bool:
    if current_time < min_spawn_time:
        return false
    if max_spawn_time > 0 and current_time > max_spawn_time:
        return false
    return true
```

### 5. WeaponData.gd
```gdscript
@tool
extends Resource
class_name WeaponData

@export var weapon_id: String = "pistol"
@export var display_name: String = "Pistol"
@export var icon: Texture2D

@export_group("Combat Stats")
@export var damage: int = 10
@export var fire_rate: float = 2.0  # Attacks per second
@export var range: float = 150.0
@export var projectile_speed: float = 300.0
@export var pierce_count: int = 0  # 0 = no pierce

@export_group("Weapon Type")
@export_enum("projectile", "melee", "magic", "orbital") var weapon_type: String = "projectile"
@export var projectile_scene: PackedScene
@export var auto_target: bool = true

@export_group("Special Properties")
@export var knockback_force: float = 0.0
@export var critical_chance: float = 0.05
@export var critical_multiplier: float = 2.0
```

## 🔧 Implementation Tasks

### Phase 1: Create Resource Classes
- [ ] Create `scripts/resources/` directory
- [ ] Implement GameConfiguration.gd
- [ ] Implement EnemyData.gd
- [ ] Implement WaveConfiguration.gd
- [ ] Implement EnemySpawnConfig.gd
- [ ] Implement WeaponData.gd

### Phase 2: Create Default Resources
- [ ] Create `resources/game_configs/default_config.tres`
- [ ] Create `resources/enemies/` with enemy data resources
- [ ] Create `resources/waves/` with wave configurations
- [ ] Create `resources/weapons/` with weapon data

### Phase 3: Update Scene Integration
- [ ] Modify RefactoredArena.gd to load resources from files
- [ ] Add @export vars for resource paths
- [ ] Implement resource validation on load
- [ ] Add fallback to programmatic creation if resources missing

### Phase 4: Create Missing System Classes
- [ ] Implement ArenaGameManager.gd
- [ ] Implement EnemySpawner.gd
- [ ] Implement UIManager.gd
- [ ] Update RefactoredArena.tscn with proper nodes

## ✅ Acceptance Criteria
- [ ] All resource classes are created and properly typed
- [ ] Resources can be created and edited in Godot editor
- [ ] Default resources exist for testing
- [ ] RefactoredArena loads resources from files
- [ ] Graceful fallback when resources are missing
- [ ] Type safety maintained throughout

## 🧪 Testing Requirements
```gdscript
# Test resource loading
func test_resource_loading():
    var config = load("res://resources/game_configs/default_config.tres")
    assert(config != null, "Config should load")
    assert(config is GameConfiguration, "Should be GameConfiguration type")
    assert(config.validate(), "Config should be valid")
    
# Test wave spawning
func test_wave_spawning():
    var wave = load("res://resources/waves/wave_1.tres")
    assert(wave.enemy_spawn_configs.size() > 0, "Should have spawn configs")
    for config in wave.enemy_spawn_configs:
        assert(config.enemy_data != null, "Should have enemy data")
```

## 📊 Performance Considerations
- Resources are loaded once and cached by Godot
- Use resource preloading for frequently accessed data
- Consider using resource UIDs for stability
- Implement lazy loading for large resource sets

## 🎨 Editor Integration Benefits
- Visual editing of game balance
- Hot reload during development
- Version control friendly (.tres files)
- Easy A/B testing with different configs
- Modding support through resource replacement

## 📝 Documentation Needed
- [ ] Resource class API documentation
- [ ] Editor workflow guide
- [ ] Resource creation examples
- [ ] Best practices for resource organization

## 🔗 Related Issues
- Depends on: #1 (Critical Fixes)
- Blocks: Performance optimizations
- Related to: Scene file organization

## 💡 Additional Notes
- Consider using `@tool` scripts for editor previews
- Implement resource validation in editor
- Add custom export hints for better UX
- Consider resource inheritance for enemy variants