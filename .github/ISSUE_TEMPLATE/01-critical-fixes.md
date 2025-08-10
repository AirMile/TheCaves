---
name: "🚨 Critical Fixes Required"
about: "Address critical bugs and missing components identified in code review"
title: "[CRITICAL] Fix missing input bindings, array bounds checks, and script references"
labels: bug, critical, good first issue
assignees: ''
---

## 🚨 Problem Summary
The code review identified several critical issues that prevent the game from running correctly. These need immediate attention before any other improvements.

## 📋 Critical Issues to Fix

### 1. ❌ Missing Debug Toggle Input Binding
**Location:** `scripts/DebugPanel.gd:61`
```gdscript
if Input.is_action_just_pressed("debug_toggle"):  # F3
```
**Problem:** The `debug_toggle` action is referenced but not defined in `project.godot`
**Impact:** Debug panel cannot be toggled, blocking performance monitoring

### 2. ❌ Array Index Out of Bounds Risk
**Location:** `scripts/autoload/EnemyPool.gd:167`
```gdscript
if pool.size() > 0:
    var enemy = pool[0]  # Get first enemy
```
**Problem:** Accessing `pool[0]` without proper bounds checking in line 167
**Impact:** Potential crash when pool is exhausted

### 3. ❌ Missing BasicEnemy.gd Script
**Location:** `scripts/autoload/EnemyPool.gd:110`
```gdscript
enemy.set_script(load("res://scripts/BasicEnemy.gd"))
```
**Problem:** Script file doesn't exist, causing enemy creation to fail
**Impact:** Enemies cannot be spawned, breaking core gameplay

### 4. ❌ Null Reference Risk in Player
**Location:** `scripts/Player.gd:118-122`
```gdscript
func _handle_movement_input(delta: float):
    if not InputManager or not movement_component:
        return
    
    # Get validated movement input
    var movement_input = InputManager.get_movement_vector()
```
**Problem:** InputManager could be null during initialization
**Impact:** Player movement fails if autoload order changes

## ✅ Acceptance Criteria
- [ ] F3 key successfully toggles debug panel visibility
- [ ] EnemyPool handles empty pools gracefully without crashes
- [ ] BasicEnemy.gd exists and implements required enemy behavior
- [ ] Player handles null InputManager without errors
- [ ] All fixes include appropriate error messages for debugging

## 🔧 Implementation Steps

### Step 1: Add Debug Toggle to project.godot
```gdscript
debug_toggle={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":4194332,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)]
}
```

### Step 2: Fix Array Bounds in EnemyPool
```gdscript
# Replace line 167-171 with:
if pool.size() > 0:
    var enemy = pool[0]
    if is_instance_valid(enemy):
        _deactivate_enemy(enemy)
        _activate_enemy(enemy)
        return enemy
```

### Step 3: Create BasicEnemy.gd
```gdscript
extends CharacterBody2D
class_name BasicEnemy

var target: Node2D = null
var speed: float = 100.0

func _ready():
    add_to_group("enemies")
    
func _physics_process(delta: float):
    if not is_instance_valid(target):
        target = get_tree().get_first_node_in_group("player")
        return
    
    var direction = global_position.direction_to(target.global_position)
    velocity = direction * speed
    move_and_slide()
```

### Step 4: Add Null Checks
```gdscript
# In Player._ready():
func _ready():
    # Wait for autoloads
    await get_tree().process_frame
    
    if not InputManager:
        push_error("Player: InputManager not found!")
        set_physics_process(false)
```

## 🧪 Testing Requirements
- [ ] Launch game without errors
- [ ] Press F3 to toggle debug panel
- [ ] Spawn 150 enemies without crashes
- [ ] Test with missing autoloads (comment out in project.godot)
- [ ] Verify error messages appear in console for failures

## 📊 Performance Impact
These fixes should have minimal performance impact but will prevent:
- Runtime crashes (array bounds)
- Missing functionality (debug panel)
- Core gameplay failures (enemy spawning)

## 🔗 Related Code Review
From PR feedback: https://github.com/AirMile/TheCaves/pull/[PR_NUMBER]
> "Array Index Out of Bounds: scripts/autoload/EnemyPool.gd:167 - accessing pool[0] without size check"
> "Missing Scene Integration: Scripts reference components that aren't present in actual .tscn files"

## 📝 Notes
- These are blocking issues that prevent basic functionality
- Should be fixed before any feature additions or optimizations
- Consider adding unit tests for these critical paths