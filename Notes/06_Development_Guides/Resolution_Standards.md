# 📐 Sprite Resolution Standards

## 🎯 Quick Decision Guide

### Voor Brotato-Style Roguelite:
**Recommended: 32x32** voor characters
- ✅ Goede balans detail vs performance
- ✅ Makkelijk te animeren
- ✅ 100+ enemies mogelijk
- ✅ Duidelijk leesbaar

## 📊 Resolution Comparison

### 16x16 - Minimal
```
Pros:
+ Ultra performance (200+ enemies)
+ Snelle productie
+ Retro aesthetic
+ Tiny file sizes

Cons:
- Weinig detail mogelijk
- Moeilijk te differentiate
- Limited animation

Best voor: Swarm enemies, bullets
```

### 32x32 - Sweet Spot ⭐
```
Pros:
+ Goede detail/performance ratio
+ Readable characters
+ Smooth animations mogelijk
+ Standaard voor indie games

Cons:
- Meer werk dan 16x16
- Grotere texture atlases

Best voor: Player, regular enemies, pickups
```

### 64x64 - Detailed
```
Pros:
+ Veel detail mogelijk
+ Impressive animations
+ Good voor bosses
+ Modern look

Cons:
- Performance impact (50-75 enemies max)
- Veel meer werk
- Larger memory footprint

Best voor: Bosses, special enemies
```

## 🎮 Mixed Resolution Strategy

### Recommended Setup:
```yaml
Player: 48x48 (belangrijk, moet opvallen)
Swarm Enemies: 24x24 (veel, klein)
Regular Enemies: 32x32 (balans)
Tank Enemies: 48x48 (imposing)
Bosses: 96x96 (epic feel)
Projectiles: 8x8 - 16x16 (performance)
Explosions: 64x64 (impact)
UI Icons: 32x32 (consistent)
```

## 📏 Technical Considerations

### Screen Coverage
```
1920x1080 screen:
- 16x16: 120x67 tiles
- 32x32: 60x33 tiles
- 64x64: 30x16 tiles

Voor 100 enemies on screen:
- 16x16: ~1.2% screen coverage
- 32x32: ~5% screen coverage
- 64x64: ~20% screen coverage
```

### Memory Usage
```
Single sprite (RGBA):
- 16x16: 1 KB
- 32x32: 4 KB
- 64x64: 16 KB

100 enemies (8 frame animation):
- 16x16: 800 KB
- 32x32: 3.2 MB
- 64x64: 12.8 MB
```

## 🎨 Art Effort Comparison

### Time per Sprite (experienced)
```
16x16: 
- Base: 15-30 min
- Animation: 1-2 hours

32x32:
- Base: 30-60 min
- Animation: 2-4 hours

64x64:
- Base: 1-2 hours
- Animation: 4-8 hours
```

## 🖼️ Visual Examples

### 32x32 Grid Layout
```
┌─────────┬─────────┬─────────┐
│ ░░██░░░ │ ▓▓██▓▓▓ │ ████████│
│ ░████░░ │ ▓████▓▓ │ ██░░░░██│
│ ██████░ │ ████████│ ██░░░░██│
│ ██░░██░ │ ██░░░░██│ ████████│
│ ██░░██░ │ ██░░░░██│ ██░░░░██│
│ ░████░░ │ ████████│ ██░░░░██│
└─────────┴─────────┴─────────┘
  Player    Enemy      Boss
```

## 🔧 Godot Setup per Resolution

### Project Settings
```gdscript
# Voor pixel perfect rendering

# 16x16 base
window/size/viewport_width = 640
window/size/viewport_height = 360
window/stretch/scale = 3

# 32x32 base
window/size/viewport_width = 960
window/size/viewport_height = 540
window/stretch/scale = 2

# 64x64 base
window/size/viewport_width = 1920
window/size/viewport_height = 1080
window/stretch/scale = 1
```

### Camera Zoom
```gdscript
# Adjust voor verschillende resolutions
@export var base_sprite_size: int = 32

func _ready():
    var zoom_level = 32.0 / base_sprite_size
    camera.zoom = Vector2(zoom_level, zoom_level)
```

## 📋 Test Matrix

### Performance Test (per resolution)
```
Test: 150 enemies + 200 projectiles

16x16:
- FPS: 60 stable ✅
- Memory: 150MB
- Draw calls: 50

32x32:
- FPS: 58-60 ✅
- Memory: 280MB
- Draw calls: 75

64x64:
- FPS: 45-55 ⚠️
- Memory: 520MB
- Draw calls: 120
```

## 🎯 Final Recommendation

### Voor Jullie Project:
```yaml
Primary Resolution: 32x32
Reasoning:
- Beste balans voor 100+ enemies
- Genoeg detail voor personality
- Jade kan het in 1-2 uur per sprite
- Proven door games als Enter the Gungeon
- Futureproof voor Steam release

Exceptions:
- Bullets: 8x8 (performance)
- Swarm enemies: 24x24 (als needed)
- Bosses: 64x64 (special moments)
```

## ✅ Resolution Checklist

Voor het kiezen:
- [ ] Test met placeholder sprites
- [ ] Check performance met 100+
- [ ] Jade comfort level met size
- [ ] Readability op 1080p
- [ ] Animation smoothness test

## 🔄 Migration Strategy

Als je wilt switchen:
```bash
16 → 32: Scale up 2x, add detail
32 → 16: Reduce, simplify shapes
32 → 64: Scale up 2x, refine

Tools:
- Aseprite: Sprite > Size (Nearest Neighbor)
- Script: Batch resize all assets
```

---

*💡 Start met 32x32, optimize later if needed!*