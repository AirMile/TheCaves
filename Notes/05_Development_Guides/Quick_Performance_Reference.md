# 🎮 TheCaves - Quick Performance Guide

## Top 3 Performance Essentials

### 1. Object Pooling (VANAF DAG 1!)
```gdscript
# Niet optioneel voor roguelites!
# Maak pools voor: enemies, projectiles, particles, damage numbers
# Zie Notes/Godot_Roguelite_Performance.md voor complete implementatie
```

### 2. LOD System 
```gdscript
# Enemies ver weg hebben geen fancy AI nodig
# < 300px: Full update
# 300-600px: Simplified AI, geen particles  
# 600-1000px: Basic movement only
# > 1000px: Position interpolation
```

### 3. Physics Layers
```gdscript
# Enemies mogen NIET onderling colliden!
# Layer 3 = Enemies
# Mask = 1 | 2 (alleen walls en player)
```

## Git Workflow (Simpel)
```bash
# Branch maken
git checkout -b feature/enemy-waves

# Committen (vaak!)
git commit -m "feat: add wave spawning"

# Push en PR maken
git push origin feature/enemy-waves
```

## Performance Targets
- 60 FPS met 100+ enemies
- < 100 draw calls
- < 500MB RAM
- Steam Deck compatible

## Testing Checklist
- [ ] FPS stabiel?
- [ ] Pooling werkt?
- [ ] LOD actief?
- [ ] Memory leaks?

**Zie `Notes/Godot_Roguelite_Performance.md` voor complete guide!**