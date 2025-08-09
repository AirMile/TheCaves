# 🎮 TheCaves - Project Instructions (Updated)

## Core Focus
Top-down roguelite with **100+ enemies** at 60 FPS. Performance is a feature!

## 🏗️ Architecture Essentials

### Object Pooling (CRUCIAL!)
All dynamic objects must be pooled:
- Enemies, projectiles, particles, damage numbers
- See: `Notes/Godot_Roguelite_Performance.md`

### Component System
```gdscript
# Use composition, not inheritance
@onready var health: HealthComponent = $HealthComponent
@onready var movement: MovementComponent = $MovementComponent
```

### LOD System
Enemies far away = less processing. Simple but effective.

## 🌿 Git Workflow 
```bash
# Feature branch → main (both new, so keep it simple)
git checkout -b feature/[name]
git commit -m "type: description"  # feat/fix/perf/art
git push → GitHub PR → Review → Merge
```

## 📊 Performance Checklist
- [ ] Object pooling active?
- [ ] LOD system working?
- [ ] Physics layers correct? (enemies not colliding with each other!)
- [ ] FPS monitor visible? (F3 toggle)
- [ ] 60 FPS with 100+ enemies?

## 🎯 Milestones Week 1-2
1. Basic pooling system
2. Enemy with LOD
3. Performance monitor HUD
4. 50+ enemies stable

## 📁 Project Structure
```
TheCaves/
├── Notes/
│   ├── Godot_Roguelite_Performance.md  # Complete guide
│   └── Quick_Performance_Reference.md  # Cheatsheet
├── autoloads/
│   ├── EnemyPool.gd
│   ├── ProjectileManager.gd
│   ├── InputManager.gd
│   └── EventBus.gd
├── components/
│   ├── HealthComponent.gd
│   └── MovementComponent.gd
└── enemies/
    └── Enemy.gd (with LOD)
```

## 🚨 Red Flags
- Enemies that collide with each other
- `instantiate()` in loops
- `get_node()` every frame
- No pooling

## ✅ Green Flags  
- Cached references
- Event bus signals
- Staggered updates
- Pool everything

**For complete implementations: see `Notes/Godot_Roguelite_Performance.md`**