# 🎮 Godot Roguelite Performance Guide - TheCaves

## 🏗️ Component System Architecture

### Waarom Components?
Voor roguelites met veel upgrades/abilities is composition veel flexibeler dan inheritance. Je kunt systems dynamisch toevoegen/verwijderen tijdens runtime.

### Basic Component Structure
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

## 🏊 Object Pooling Pattern (CRUCIAAL!)

### Complete Pool Implementation
```gdscript
# Autoloads/EnemyPool.gd
extends Node

var pools: Dictionary = {}
const POOL_SIZES = {
    "bat": 50,
    "spider": 50,
    "golem": 30,
    "skeleton": 40,
    "projectile": 200,
    "particle_hit": 100,
    "particle_death": 50
}

func _ready() -> void:
    _create_pools()

func _create_pools() -> void:
    for type in POOL_SIZES:
        pools[type] = []
        var scene_path = "res://enemies/%s.tscn" % type if type.contains("particle") == false else "res://effects/%s.tscn" % type
        var scene = load(scene_path)
        
        for i in POOL_SIZES[type]:
            var instance = scene.instantiate()
            instance.set_process(false)
            instance.set_physics_process(false)
            instance.visible = false
            add_child(instance)
            pools[type].append(instance)

func get_enemy(type: String) -> Enemy:
    for enemy in pools[type]:
        if not enemy.active:
            enemy.activate()
            return enemy
    
    # Pool exhausted - reuse oldest
    push_warning("Pool exhausted for: " + type)
    var oldest = pools[type][0]
    oldest.deactivate()
    oldest.activate()
    return oldest

func return_to_pool(object: Node) -> void:
    object.deactivate()
```

## 📊 Level of Detail (LOD) System

### Complete LOD Implementation
```gdscript
# Enemy.gd
extends CharacterBody2D
class_name Enemy

enum LOD { FULL, MEDIUM, LOW, MINIMAL }
var current_lod: LOD = LOD.FULL
var player_ref: Node2D
var last_lod_check: float = 0.0
const LOD_CHECK_INTERVAL: float = 0.2  # Check 5x per second

func _ready():
    player_ref = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
    # Stagger LOD checks
    last_lod_check += delta
    if last_lod_check > LOD_CHECK_INTERVAL:
        last_lod_check = 0.0
        update_lod()
    
    # Process based on LOD
    match current_lod:
        LOD.FULL:
            _full_update(delta)
        LOD.MEDIUM:
            _medium_update(delta)
        LOD.LOW:
            _low_update(delta)
        LOD.MINIMAL:
            _minimal_update(delta)

func update_lod() -> void:
    if not player_ref:
        return
        
    var distance = global_position.distance_to(player_ref.global_position)
    
    # Hysteresis to prevent LOD flickering
    var new_lod = current_lod
    
    if distance < 250:
        new_lod = LOD.FULL
    elif distance < 500 and current_lod != LOD.FULL:
        new_lod = LOD.MEDIUM
    elif distance < 800 and current_lod > LOD.MEDIUM:
        new_lod = LOD.LOW
    elif distance > 900:
        new_lod = LOD.MINIMAL
    
    if new_lod != current_lod:
        _transition_lod(current_lod, new_lod)
        current_lod = new_lod

func _full_update(delta: float) -> void:
    # Everything enabled
    _update_ai(delta)
    _update_animation()
    _check_abilities()
    _update_particles()
    move_and_slide()

func _medium_update(delta: float) -> void:
    # No particles, simplified AI
    _update_simple_ai(delta)
    _update_animation()
    move_and_slide()

func _low_update(delta: float) -> void:
    # Basic movement only
    _move_toward_player(delta)
    move_and_slide()
    # No animations

func _minimal_update(delta: float) -> void:
    # Just interpolate position
    global_position = global_position.lerp(player_ref.global_position, delta * 0.5)
```

## 🎯 Physics Layer Optimization

### Layer Setup
```gdscript
# Project Settings - Layer Names
# Layer 1: Walls
# Layer 2: Player  
# Layer 3: Enemies
# Layer 4: Player Projectiles
# Layer 5: Enemy Projectiles
# Layer 6: Pickups
# Layer 7: Triggers

# Enemy Setup - GEEN onderlinge collision!
func _ready():
    collision_layer = 3  # Enemy layer
    collision_mask = 1 | 2  # Only walls and player
    
# Player Setup
func _ready():
    collision_layer = 2  # Player layer
    collision_mask = 1 | 3 | 5 | 6  # Walls, enemies, enemy projectiles, pickups
```

## 🔄 State Machine Pattern

### Complete State Machine
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
            child.owner_ref = owner
    
    if initial_state:
        initial_state.enter()
        current_state = initial_state

func transition_to(state_name: String) -> void:
    if not states.has(state_name):
        push_warning("State not found: " + state_name)
        return
    
    if current_state:
        current_state.exit()
    
    current_state = states[state_name]
    current_state.enter()

func _physics_process(delta):
    if current_state:
        current_state.physics_update(delta)

# State.gd
extends Node
class_name State

var state_machine: StateMachine
var owner_ref: Node

func enter() -> void:
    pass

func exit() -> void:
    pass

func physics_update(_delta: float) -> void:
    pass
```

## 📡 Event Bus System

### Complete Event Bus
```gdscript
# Autoloads/EventBus.gd
extends Node

# Game Events
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal enemy_spawned(enemy: Enemy)
signal enemy_killed(enemy: Enemy, killer: Node)

# Player Events  
signal player_damaged(amount: int)
signal player_healed(amount: int)
signal player_died()
signal ability_used(ability_name: String)
signal level_up(new_level: int)

# Upgrade Events
signal upgrade_collected(upgrade: Upgrade)
signal upgrade_applied(upgrade_name: String)

# UI Events
signal score_changed(new_score: int)
signal show_damage_number(position: Vector2, damage: int, is_crit: bool)
signal screen_shake(intensity: float, duration: float)

# Performance Events
signal performance_warning(fps: int, enemy_count: int)

# Usage Example:
func _ready():
    EventBus.enemy_killed.connect(_on_enemy_killed)
    
func kill_enemy(enemy):
    EventBus.enemy_killed.emit(enemy, self)
```

## 🎮 Input System (Multiplayer-Ready)

### Complete Input Manager
```gdscript
# Autoloads/InputManager.gd
extends Node

var input_vector: Vector2 = Vector2.ZERO
var aim_direction: Vector2 = Vector2.RIGHT
var dash_pressed: bool = false
var ability_inputs: Dictionary = {}
var using_controller: bool = false
var controller_id: int = 0

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
    
    # Update aim
    update_aim_direction()

func detect_input_method():
    # Check for keyboard input
    if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
        using_controller = false
    # Check for controller input
    elif abs(Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_X)) > 0.1:
        using_controller = true

func update_aim_direction():
    if using_controller:
        # Right stick for aiming
        var aim = Vector2(
            Input.get_joy_axis(controller_id, JOY_AXIS_RIGHT_X),
            Input.get_joy_axis(controller_id, JOY_AXIS_RIGHT_Y)
        )
        if aim.length() > 0.5:
            aim_direction = aim.normalized()
    else:
        # Mouse aiming
        var player = get_tree().get_first_node_in_group("player")
        if player:
            aim_direction = (player.get_global_mouse_position() - player.global_position).normalized()

func _on_joy_connection_changed(device: int, connected: bool):
    if connected:
        print("Controller %d connected" % device)
        controller_id = device
    else:
        print("Controller %d disconnected" % device)
```

## 📊 Performance Monitor

### Debug HUD
```gdscript
# UI/DebugPanel.gd
extends PanelContainer

@onready var fps_label = $VBox/FPS
@onready var enemies_label = $VBox/Enemies
@onready var projectiles_label = $VBox/Projectiles
@onready var draw_calls_label = $VBox/DrawCalls
@onready var memory_label = $VBox/Memory

var update_timer: float = 0.0
const UPDATE_INTERVAL: float = 0.1  # Update 10x per second

func _ready():
    visible = OS.is_debug_build()
    modulate.a = 0.8  # Semi-transparent

func _process(delta):
    if not visible:
        return
    
    update_timer += delta
    if update_timer < UPDATE_INTERVAL:
        return
    update_timer = 0.0
    
    # Update labels
    var fps = Engine.get_frames_per_second()
    fps_label.text = "FPS: %d" % fps
    fps_label.modulate = Color.GREEN if fps >= 55 else Color.YELLOW if fps >= 45 else Color.RED
    
    enemies_label.text = "Enemies: %d" % get_tree().get_nodes_in_group("enemies").size()
    projectiles_label.text = "Projectiles: %d" % get_tree().get_nodes_in_group("projectiles").size()
    draw_calls_label.text = "Draw Calls: %d" % RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
    
    var memory_mb = OS.get_static_memory_usage() / 1048576.0
    memory_label.text = "Memory: %.1f MB" % memory_mb
    
    # Performance warning
    if fps < 50 and get_tree().get_nodes_in_group("enemies").size() > 50:
        EventBus.performance_warning.emit(fps, get_tree().get_nodes_in_group("enemies").size())

func _input(event):
    if event.is_action_just_pressed("debug_toggle"):  # F3
        visible = !visible
```

## 🚀 Projectile System

### Optimized Projectile Manager
```gdscript
# Autoloads/ProjectileManager.gd
extends Node2D

var projectile_pool: Array[Projectile] = []
const POOL_SIZE = 500

func _ready():
    _create_pool()

func _create_pool():
    var projectile_scene = preload("res://projectiles/BasicProjectile.tscn")
    for i in POOL_SIZE:
        var proj = projectile_scene.instantiate()
        proj.visible = false
        proj.set_physics_process(false)
        add_child(proj)
        projectile_pool.append(proj)

func spawn_projectile(pos: Vector2, dir: Vector2, speed: float, damage: int, team: String = "player") -> void:
    var proj = _get_from_pool()
    if not proj:
        return
    
    proj.setup(pos, dir, speed, damage, team)
    proj.activate()

func _get_from_pool() -> Projectile:
    for proj in projectile_pool:
        if not proj.active:
            return proj
    
    push_warning("Projectile pool exhausted!")
    return null

# Projectile.gd
extends Area2D
class_name Projectile

var velocity: Vector2
var damage: int
var team: String
var active: bool = false
var lifetime: float = 0.0
const MAX_LIFETIME: float = 5.0

func setup(pos: Vector2, dir: Vector2, speed: float, dmg: int, t: String):
    global_position = pos
    velocity = dir.normalized() * speed
    damage = dmg
    team = t
    lifetime = 0.0
    
    # Set collision based on team
    if team == "player":
        collision_layer = 4  # Player projectiles
        collision_mask = 3   # Hit enemies
    else:
        collision_layer = 5  # Enemy projectiles
        collision_mask = 2   # Hit player

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
    ProjectileManager.return_to_pool(self)

func _physics_process(delta):
    if not active:
        return
    
    position += velocity * delta
    lifetime += delta
    
    # Check if outside screen or lifetime exceeded
    if lifetime > MAX_LIFETIME or is_outside_screen():
        deactivate()

func is_outside_screen() -> bool:
    var viewport_rect = get_viewport_rect()
    return not viewport_rect.has_point(global_position)

func _on_body_entered(body):
    if body.has_method("take_damage"):
        body.take_damage(damage)
        EventBus.show_damage_number.emit(global_position, damage, randf() < 0.1)  # 10% crit chance
    deactivate()
```

## ⚡ Performance Optimization Checklist

### Per Feature Checklist
- [ ] Object pooling geïmplementeerd?
- [ ] LOD system voor verre objecten?
- [ ] Collision layers correct (geen onnodige checks)?
- [ ] Node references gecached (geen get_node elke frame)?
- [ ] Signals gebruikt voor communication (geen polling)?
- [ ] Particles gepooled?
- [ ] Texture atlases gebruikt?
- [ ] Draw calls < 100?
- [ ] FPS stabiel op 60 met 100+ enemies?

### Red Flags 🚫
```gdscript
# ❌ SLECHT
func _process(delta):
    var player = get_node("/root/Game/Player")  # Elke frame opzoeken
    label.text = "Health: " + str(health)  # String concatenation
    
    for i in 100:
        var bullet = bullet_scene.instantiate()  # Nieuwe objects

# ✅ GOED
@onready var player = get_node("/root/Game/Player")  # Cache reference
var health_format = "Health: %d"

func _process(delta):
    label.text = health_format % health  # Format string
    
    for i in 100:
        var bullet = bullet_pool.get_bullet()  # Pool gebruiken
```

## 📈 Target Performance Metrics

### Minimum Requirements
- **FPS**: 60 stable (55 absolute minimum)
- **Enemies**: 100-150 simultaneous
- **Projectiles**: 200-300 active
- **Particles**: 50-100 systems
- **Draw Calls**: < 100
- **Memory**: < 500MB RAM
- **Load Time**: < 3 seconds

### Steam Deck Specifics
- **Resolution**: 1280x800
- **Target FPS**: 60 (kan naar 40 voor battery)
- **TDP**: 10-15W voor lange sessies
- **Memory**: Max 12GB beschikbaar

## 🎯 Testing Scenarios

### Stress Test Setup
```gdscript
# DevCommands.gd
func spawn_stress_test():
    for i in 150:
        var enemy = EnemyPool.get_enemy("bat")
        enemy.global_position = Vector2(randf() * 1920, randf() * 1080)
    
    for i in 200:
        ProjectileManager.spawn_projectile(
            Vector2(randf() * 1920, randf() * 1080),
            Vector2.RIGHT.rotated(randf() * TAU),
            300,
            10
        )
    
    print("Stress test started: 150 enemies, 200 projectiles")
```

---

*Deze guide is specifiek voor TheCaves roguelite project. Update regelmatig based op testing!*