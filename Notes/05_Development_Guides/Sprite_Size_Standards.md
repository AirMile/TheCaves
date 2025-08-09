# 📐 Sprite Size Standards - TheCaves

## 🎯 Quick Decision Guide

### Voor TheCaves Roguelite:
**Besluit: Start met deze sizes**
- Player: **48x48** 
- Regular Enemies: **32x32** en **48x48** mix
- Boss: **128x128**
- Projectiles: **8x8** of **16x16**

## 📊 Size Comparison Table

### Based on Godot Docs + Proven Roguelites

| Entity | Recommended | Alternative | Why This Size | Reference Games |
|--------|-------------|-------------|---------------|-----------------|
| **Player** | 48x48 | 64x64 | Visible, not overwhelming | Brotato (48x48) |
| **Swarm Enemy** | 32x32 | 24x24 | Performance, 150+ on screen | Vampire Survivors |
| **Regular Enemy** | 48x48 | 32x32 | Good detail/performance | Enter the Gungeon |
| **Elite Enemy** | 64x64 | 48x48 | Imposing but manageable | Nuclear Throne |
| **Boss** | 128x128 | 96x96, 192x192 | Epic scale, 2.5x player | Isaac bosses |
| **Mini-Boss** | 96x96 | 64x64 | Between regular and boss | Gungeon mini-bosses |
| **Projectiles** | 8x8, 16x16 | 12x12 | Max performance | All bullet hells |
| **Pickups** | 16x16, 24x24 | 32x32 | Small, recognizable | Standard |

## 🎮 Resolution Context

### Godot Recommended Base Resolution
```yaml
Base: 640x360
Upscales to:
  - 1280x720 (2x)
  - 1920x1080 (3x)
  - 2560x1440 (4x)
```

### Screen Coverage at 640x360
```
48x48 player = 7.5% of screen width
32x32 enemy = 5% of screen width
128x128 boss = 20% of screen width
```

## 📏 Visual Size Hierarchy

```
Must Follow This Rule:
Projectile < Pickup < Small Enemy < Regular Enemy < Player < Elite < Boss

Actual Sizes:
   8px      16px        32px          48px        48px    64px   128px
```

### Important: Player MUST Stand Out
- Player same size or LARGER than regular enemies
- Use unique color/glow for player
- Player gets priority rendering

## 🎨 Art Production Impact

### Time per Sprite (Jade's Planning)
```yaml
32x32:
  Sketch: 15 min
  Base Sprite: 30-45 min
  Animation (8 frames): 2-3 hours
  Total: 3-4 hours

48x48:
  Sketch: 20 min
  Base Sprite: 45-60 min
  Animation (8 frames): 3-4 hours
  Total: 4-5 hours

64x64:
  Sketch: 30 min
  Base Sprite: 60-90 min
  Animation (8 frames): 4-6 hours
  Total: 5-7 hours

128x128:
  Sketch: 45 min
  Base Sprite: 2-3 hours
  Animation (8 frames): 8-12 hours
  Total: 10-15 hours
```

## 💾 Memory Budget

### Per Entity Type (with 8-frame animations)
```
Player (48x48): 72KB
Swarm Enemy (32x32): 32KB x 150 = 4.8MB
Regular Enemy (48x48): 72KB x 50 = 3.6MB
Elite Enemy (64x64): 128KB x 10 = 1.3MB
Boss (128x128): 512KB x 2 = 1MB
Total Estimate: ~11MB (well under 500MB limit)
```

## 🔧 Texture Atlas Organization

### Efficient Packing
```yaml
Atlas 1 (512x512): # Small sprites
  - 16x16 grid of 32x32 sprites
  - Can fit: 256 small enemies
  - Use for: Swarm enemies, projectiles

Atlas 2 (1024x1024): # Medium sprites  
  - 21x21 grid of 48x48 sprites
  - Can fit: 441 sprites
  - Use for: Player, regular enemies

Atlas 3 (2048x2048): # Large sprites
  - 16x16 grid of 128x128 sprites
  - Can fit: 256 boss/elite sprites
  - Use for: Bosses, large effects
```

## ✅ Decision Checklist

### Before Finalizing Sizes:
- [x] Player is visible among enemies?
- [x] Enemies fit performance budget?
- [x] Boss feels imposing?
- [x] Projectiles clear but small?
- [x] Fits Godot's integer scaling?
- [x] Power of 2 friendly?
- [x] Art production time realistic?

## 🎯 FINAL RECOMMENDATION

### Start Development With:
```ini
[sprites]
player = 48x48
enemy_swarm = 32x32
enemy_regular = 48x48
enemy_elite = 64x64
boss = 128x128
mini_boss = 96x96
projectile_small = 8x8
projectile_large = 16x16
pickup = 24x24
```

### If Performance Issues:
1. Reduce regular enemies to 32x32
2. Reduce elite enemies to 48x48
3. Use LOD system aggressively
4. Reduce animation frames

### If Too Small/Ugly:
1. Only if FPS stays 60+
2. Increase player to 64x64
3. Increase regular enemies to 48x48
4. Keep swarm enemies at 32x32 always

## 📝 Notes for Team

### Voor Miles:
- Start coding with 48x48 player placeholder
- Test spawning with 32x32 enemies
- Implement LOD system early

### Voor Jade:
- Begin with 48x48 player sprite
- Make 32x32 test enemy
- Try both sizes, see what feels better
- Don't over-detail small sprites

---

*Decision Date: December 2024*
*Can be revised after performance testing*