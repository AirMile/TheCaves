# 🎮 Godot Best Practices voor Roguelites

## 📊 Performance First (100+ Enemies)

### 1. Object Pooling Pattern
```gdscript
# EnemyPool.gd (Autoload)
extends Node

var enemy_pools: Dictionary = {}
var pool_size: int = 200

func _ready() -> void:
    # Pre-spawn enemies voor elke type
    for enemy_type in ["swarm", "tank", "ranged"]:
        enemy_pools[enemy_type] = []
        var scene = load("res://scenes/enemies/Enemy%s.tscn" % enemy_type.capitalize())
        
        for i in pool_size / 3:  # ~66 per type
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
    
    # Pool empty? Reuse oldest
    print("Warning: Enemy pool exhausted for type: ", type)
    return pool[0]  # Force reuse

func return_enemy(enemy: Enemy) -> void:
    enemy.deactivate()
```

### 2. Collision Optimization
```gdscript
# Project Settings voor collision layers:
# Layer 1: Walls
# Layer 2: Player  
# Layer 3: Enemies
# Layer 4: Player Projectiles
# Layer 5: Enemy Projectiles
# Layer 6: Pickups

# Enemy.gd - Efficient collision setup
func _ready():
    collision_layer = 3  # Enemy layer
    collision_mask = 1 | 2 | 4  # Walls, Player, Player Projectiles
    # Enemies onderling NIET laten colliden!
```

### 3. LOD (Level of Detail) System
```gdscript
# Enemy.gd
extends CharacterBody2D

enum DetailLevel { HIGH, MEDIUM, LOW, MINIMAL }
var current_lod: DetailLevel = DetailLevel.HIGH
var player_ref: Node2D

func _ready():
    player_ref = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
    update_lod()
    
    match current_lod:
        DetailLevel.HIGH:
            full_ai_update(delta)
            update_animation()
            check_abilities()
        DetailLevel.MEDIUM:
            simple_ai_update(delta)
            update_animation()
        DetailLevel.LOW:
            basic_movement(delta)
            # Skip animations
        DetailLevel.MINIMAL:
            # Alleen position updates
            pass

func update_lod() -> void:
    var distance = global_position.distance_to(player_ref.global_position)
    
    if distance < 300:
        current_lod = DetailLevel.HIGH
    elif distance < 600:
        current_lod = DetailLevel.MEDIUM
    elif distance < 1000:
        current_lod = DetailLevel.LOW
    else:
        current_lod = DetailLevel.MINIMAL
```

## 🏗️ Architecture Patterns

### 1. Component System (Composition)
```gdscript
# Components/HealthComponent.gd
extends Node
class_name HealthComponent

signal died
signal health_changed(new_health: int)

@export var max_health: int = 100
var current_health: int

func _ready():
    current_health = max_health

func take_damage(amount: int) -> void:
    current_health = max(0, current_health - amount)
    health_changed.emit(current_health)
    
    if current_health <= 0:
        died.emit()

# Enemy.gd - Gebruik components
@onready var health: HealthComponent = $HealthComponent
@onready var movement: MovementComponent = $MovementComponent
@onready var ai: AIComponent = $AIComponent

func _ready():
    health.died.connect(_on_death)
```

### 2. State Machine Pattern
```gdscript
# StateMachine.gd
extends Node
class_name StateMachine

@export var initial_state: State
var current_state: State
var states: Dictionary = {}

func _ready():
    for child in get_children():
        if child is State:
            states[child.name.to_lower()] = child
            child.state_machine = self
    
    if initial_state:
        initial_state.enter()
        current_state = initial_state

func transition_to(state_name: String) -> void:
    if not states.has(state_name):
        return
    
    if current_state:
        current_state.exit()
    
    current_state = states[state_name]
    current_state.enter()

# States/IdleState.gd
extends State

func enter():
    owner.velocity = Vector2.ZERO

func physics_update(delta: float):
    if owner.target:
        state_machine.transition_to("chase")
```

### 3. Event Bus (Signals)
```gdscript
# EventBus.gd (Autoload)
extends Node

# Game events
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal enemy_spawned(enemy: Enemy)
signal enemy_killed(enemy: Enemy, killer: Node)

# Player events  
signal player_damaged(amount: int)
signal player_healed(amount: int)
signal ability_used(ability_name: String)

# Upgrade events
signal upgrade_collected(upgrade: Upgrade)
signal level_up(new_level: int)

# UI events
signal score_changed(new_score: int)
signal show_damage_number(position: Vector2, damage: int, is_crit: bool)

# Usage:
# EventBus.enemy_killed.connect(_on_enemy_killed)
```

## 🎯 Projectile System

### Efficient Bullet Hell
```gdscript
# ProjectileManager.gd (Autoload)
extends Node2D

var projectile_pool: Array[Projectile] = []
const POOL_SIZE = 500

func _ready():
    # Pre-instantiate projectiles
    var projectile_scene = preload("res://scenes/Projectile.tscn")
    for i in POOL_SIZE:
        var proj = projectile_scene.instantiate()
        proj.visible = false
        proj.set_physics_process(false)
        add_child(proj)
        projectile_pool.append(proj)

func spawn_projectile(pos: Vector2, dir: Vector2, speed: float, damage: int) -> void:
    var proj = get_from_pool()
    if not proj:
        return
    
    proj.setup(pos, dir, speed, damage)
    proj.activate()

func get_from_pool() -> Projectile:
    for proj in projectile_pool:
        if not proj.active:
            return proj
    return null  # Pool exhausted

# Projectile.gd
extends Area2D
class_name Projectile

var velocity: Vector2
var damage: int
var active: bool = false
var lifetime: float = 0.0
const MAX_LIFETIME: float = 5.0

func setup(pos: Vector2, dir: Vector2, speed: float, dmg: int):
    global_position = pos
    velocity = dir.normalized() * speed
    damage = dmg
    lifetime = 0.0

func activate():
    active = true
    visible = true
    set_physics_process(true)
    monitoring = true

func deactivate():
    active = false
    visible = false
    set_physics_process(false)
    monitoring = false

func _physics_process(delta):
    if not active:
        return
    
    position += velocity * delta
    lifetime += delta
    
    if lifetime > MAX_LIFETIME or is_outside_screen():
        ProjectileManager.return_to_pool(self)

func _on_body_entered(body):
    if body.has_method("take_damage"):
        body.take_damage(damage)
    deactivate()
```

## 🎮 Input System

### Flexible Input Handling
```gdscript
# InputManager.gd (Autoload)
extends Node

var input_vector: Vector2 = Vector2.ZERO
var dash_pressed: bool = false
var ability_inputs: Dictionary = {}
var using_controller: bool = false

func _ready():
    Input.joy_connection_changed.connect(_on_joy_connection_changed)

func _process(_delta):
    # Movement input
    input_vector.x = Input.get_axis("move_left", "move_right")
    input_vector.y = Input.get_axis("move_up", "move_down")
    
    # Normalize diagonal movement
    if input_vector.length() > 1.0:
        input_vector = input_vector.normalized()
    
    # Abilities
    dash_pressed = Input.is_action_just_pressed("dash")
    
    for i in range(1, 5):  # 4 ability slots
        var action = "ability_%d" % i
        ability_inputs[i] = Input.is_action_just_pressed(action)
    
    # Detect input method
    detect_input_method()

func detect_input_method():
    if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
        using_controller = false
    elif abs(Input.get_joy_axis(0, JOY_AXIS_LEFT_X)) > 0.1:
        using_controller = true

func get_aim_direction() -> Vector2:
    if using_controller:
        # Right stick for aiming
        var aim = Vector2(
            Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),
            Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
        )
        if aim.length() > 0.5:
            return aim.normalized()
    else:
        # Mouse aiming
        var player = get_tree().get_first_node_in_group("player")
        if player:
            return (get_global_mouse_position() - player.global_position).normalized()
    
    return Vector2.RIGHT  # Default direction
```

## 📈 Upgrade System

### Modular Upgrades
```gdscript
# Upgrade.gd
extends Resource
class_name Upgrade

@export var id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var icon: Texture2D
@export var max_level: int = 5
@export var stat_modifiers: Dictionary = {}  # {"damage": 1.2, "speed": 1.1}

func apply(target: Node, level: int) -> void:
    for stat in stat_modifiers:
        if target.has_property(stat):
            var modifier = stat_modifiers[stat]
            var current = target.get(stat)
            target.set(stat, current * pow(modifier, level))

# UpgradeManager.gd
extends Node

var active_upgrades: Dictionary = {}  # upgrade_id: level
var available_upgrades: Array[Upgrade] = []

func add_upgrade(upgrade: Upgrade) -> void:
    var id = upgrade.id
    
    if active_upgrades.has(id):
        # Level up existing
        active_upgrades[id] = min(active_upgrades[id] + 1, upgrade.max_level)
    else:
        # Add new
        active_upgrades[id] = 1
    
    apply_upgrade(upgrade, active_upgrades[id])

func apply_upgrade(upgrade: Upgrade, level: int) -> void:
    var player = get_tree().get_first_node_in_group("player")
    upgrade.apply(player, level)
    EventBus.upgrade_collected.emit(upgrade)
```

## 🎵 Audio System

### Efficient Audio Pooling
```gdscript
# AudioManager.gd (Autoload)
extends Node

var sfx_players: Array[AudioStreamPlayer2D] = []
const SFX_POOL_SIZE = 20

func _ready():
    # Create audio player pool
    for i in SFX_POOL_SIZE:
        var player = AudioStreamPlayer2D.new()
        player.bus = "SFX"
        add_child(player)
        sfx_players.append(player)

func play_sfx(sound: AudioStream, position: Vector2, volume: float = 0.0):
    for player in sfx_players:
        if not player.playing:
            player.stream = sound
            player.global_position = position
            player.volume_db = volume
            player.pitch_scale = randf_range(0.9, 1.1)  # Variation
            player.play()
            return
```

## 🔧 Debug Tools

### In-Game Debug Panel
```gdscript
# DebugPanel.gd
extends PanelContainer

@onready var fps_label = $VBox/FPS
@onready var enemies_label = $VBox/Enemies
@onready var projectiles_label = $VBox/Projectiles

func _ready():
    visible = OS.is_debug_build()

func _process(_delta):
    if not visible:
        return
    
    fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
    enemies_label.text = "Enemies: %d" % get_tree().get_nodes_in_group("enemies").size()
    projectiles_label.text = "Projectiles: %d" % get_tree().get_nodes_in_group("projectiles").size()
    
    # Toggle with F3
    if Input.is_action_just_pressed("debug_toggle"):
        visible = !visible
```

## ⚙️ Project Settings

### Optimal Settings voor Roguelites
```ini
# project.godot aanpassingen

[rendering]
textures/canvas_textures/default_texture_filter=1  # Pixel perfect
driver/threads/thread_model=2  # Multi-threaded

[physics]
2d/default_gravity=0.0  # Top-down game
common/physics_ticks_per_second=60
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
GameManager="*res://scripts/autoload/GameManager.gd"
InputManager="*res://scripts/autoload/InputManager.gd"
AudioManager="*res://scripts/autoload/AudioManager.gd"
EnemyPool="*res://scripts/autoload/EnemyPool.gd"
ProjectileManager="*res://scripts/autoload/ProjectileManager.gd"
```

## 🚀 Multiplayer Preparation

### Network-Ready Structure
```gdscript
# Player.gd - Multiplayer ready
extends CharacterBody2D

@export var player_id: int = 1
var is_local_player: bool = true

func _ready():
    if not is_local_player:
        set_physics_process(false)  # Only process local player
        $Camera2D.enabled = false

func _physics_process(delta):
    if is_local_player:
        handle_input()
        move_and_slide()
        sync_position()  # Future: send to network

func handle_input():
    # Input only for local player
    velocity = InputManager.input_vector * move_speed
```

## 📝 Code Standards

### Naming Conventions
```gdscript
# Classes: PascalCase
class_name PlayerController

# Files: snake_case
player_controller.gd

# Constants: UPPER_SNAKE_CASE
const MAX_HEALTH: int = 100

# Variables: snake_case
var current_health: int

# Signals: snake_case
signal health_changed

# Functions: snake_case
func take_damage(amount: int) -> void:
    pass

# Private functions: _underscore_prefix
func _update_health_bar() -> void:
    pass
```

## 🎯 Performance Targets

- **FPS**: 60 stable (55 minimum)
- **Enemies on screen**: 100-150
- **Projectiles**: 200-300
- **Particles**: Limited, use object pooling
- **Draw calls**: < 100
- **Physics bodies**: < 200 active

---

*💡 Remember: Premature optimization is evil, but in roguelites, performance IS a feature!*