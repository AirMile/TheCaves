# 🎮 TheCaves - Project Instructions (Updated)

## Core Focus
Top-down roguelite met **100+ enemies** op 60 FPS. Performance is een feature!

## 🏗️ Architecture Essentials

### Object Pooling (CRUCIAAL!)
Alle dynamic objects moeten gepooled worden:
- Enemies, projectiles, particles, damage numbers
- Zie: `Notes/Godot_Roguelite_Performance.md`

### Component System
```gdscript
# Gebruik composition, niet inheritance
@onready var health: HealthComponent = $HealthComponent
@onready var movement: MovementComponent = $MovementComponent
```

### LOD System
Enemies ver weg = minder processing. Simpel maar effectief.

## 🌿 Git Workflow 
```bash
# Feature branch → main (beide nieuw, dus simpel houden)
git checkout -b feature/[naam]
git commit -m "type: description"  # feat/fix/perf/art
git push → GitHub PR → Review → Merge
```

## 📊 Performance Checklist
- [ ] Object pooling actief?
- [ ] LOD system werkt?
- [ ] Physics layers correct? (enemies niet onderling!)
- [ ] FPS monitor zichtbaar? (F3 toggle)
- [ ] 60 FPS met 100+ enemies?

## 🎯 Milestones Week 1-2
1. Basic pooling system
2. Enemy met LOD
3. Performance monitor HUD
4. 50+ enemies stabiel

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
    └── Enemy.gd (met LOD)
```

## 🚨 Red Flags
- Enemies die onderling colliden
- `instantiate()` in loops
- `get_node()` elke frame
- Geen pooling

## ✅ Green Flags  
- Cached references
- Event bus signals
- Staggered updates
- Pool everything

**Voor complete implementaties: zie `Notes/Godot_Roguelite_Performance.md`**