# 🎮 Sprite Performance Guide - TheCaves

## 📏 Godot-Recommended Sprite Sizes

### Official Godot Documentation Guidelines

#### Voor Pixel Art Games (Godot Docs)
```
Base Window Size: 640x360
  - Schaalt perfect naar: 1280x720, 1920x1080
  - Integer scaling friendly
  
Stretch Settings:
  - Mode: viewport
  - Aspect: keep (fixed) of expand (flexible)
  - Scale Mode: integer (pixel perfect)
```

#### Sprite Size Recommendations
```yaml
# Based on 640x360 base resolution
Player: 48x48 (7.5% of screen width)
Regular Enemy: 32x32 (5% of screen width)
Small Enemy: 24x24 (3.75% of screen width)
Boss: 128x128 (20% of screen width)
Projectiles: 8-16px
```

## 🎯 TheCaves Sprite Standards

### Size Hierarchy (FINAL)
```
Projectile < Pickup < Enemy < Player < Elite < Boss
    8px      16px    32px    48px    64px   128px
```

### Recommended Setup
| Entity Type | Size | Max on Screen | Priority |
|------------|------|---------------|----------|
| **Player** | 48x48 | 1-4 | HIGH |
| **Swarm Enemy** | 32x32 | 150-200 | HIGH |
| **Regular Enemy** | 48x48 | 75-100 | HIGH |
| **Elite Enemy** | 64x64 | 20-30 | MEDIUM |
| **Boss** | 128x128 | 1-3 | HIGH |
| **Projectiles** | 8x8 or 16x16 | 200+ | HIGH |
| **Pickups** | 16x16 or 24x24 | 50+ | LOW |

## 🔧 Godot Texture Settings

### Import Settings voor Pixel Art
```ini
[remap]
importer="texture"
type="CompressedTexture2D"

[params]
compress/mode=0  # Lossless
mipmaps/generate=false  # No mipmaps voor 2D
filter=0  # Nearest neighbor
```

### Texture Atlas Requirements
```gdscript
# Power of 2 dimensions (Godot requirement)
const ATLAS_SIZES = {
    "small": Vector2(512, 512),    # 32x32 sprites
    "medium": Vector2(1024, 1024),  # 48-64px sprites
    "large": Vector2(2048, 2048)    # 128px+ sprites
}
```

## 📊 Memory & Performance Impact

### Memory per Sprite (RGBA8, no mipmaps)
```
32x32: 4KB per frame
48x48: 9KB per frame
64x64: 16KB per frame
128x128: 64KB per frame

With 8-frame animation:
32x32: 32KB total
48x48: 72KB total
64x64: 128KB total
128x128: 512KB total
```

### Performance Targets
```gdscript
# Monitor in Godot
Engine.get_frames_per_second() >= 60
RenderingServer.get_rendering_info(
    RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME
) < 100
OS.get_static_memory_usage() < 500_000_000  # 500MB
```

## 🎨 Sprite Production Guidelines

### Time Investment per Sprite
| Size | Base Sprite | Animation (8 frames) | Total Time |
|------|------------|---------------------|------------|
| 32x32 | 30-45 min | 2-3 hours | 3-4 hours |
| 48x48 | 45-60 min | 3-4 hours | 4-5 hours |
| 64x64 | 60-90 min | 4-6 hours | 5-7 hours |
| 128x128 | 2-3 hours | 8-12 hours | 10-15 hours |

### Priority Order for Jade
1. **Player sprite** (48x48) - Most important
2. **Basic enemy** (32x32) - For testing spawning
3. **Regular enemy** (48x48) - Combat variety
4. **Boss** (128x128) - Epic moments
5. **Projectiles** (8x8, 16x16) - Performance testing
6. **Elite enemies** (64x64) - Mid-game content

## 🌟 Neon Glow Implementation

### WorldEnvironment Settings (2D Glow zonder HDR)
```gdscript
extends WorldEnvironment

func setup_2d_glow():
    environment.background_mode = Environment.BG_CANVAS
    environment.glow_enabled = true
    environment.glow_intensity = 1.0
    environment.glow_strength = 1.2
    environment.glow_bloom = 0.1
    environment.glow_blend_mode = Environment.GLOW_BLEND_MODE_SCREEN
    environment.glow_hdr_threshold = 0.5  # Lower voor non-HDR
```

### Sprite Glow Layers
```
Layer 1: Base sprite (dark silhouette)
Layer 2: Inner glow (bright core color)
Layer 3: Outer glow (softer, larger)
Layer 4: WorldEnvironment bloom (automatic)
```

## 🎯 LOD System voor Performance

```gdscript
# Distance-based detail reduction
extends Node2D

enum LOD { FULL, MEDIUM, LOW, CULLED }

@export var lod_distances = {
    LOD.FULL: 300,     # All features
    LOD.MEDIUM: 600,   # Reduced animation
    LOD.LOW: 1000,     # Static sprite
    LOD.CULLED: 1500   # Hidden
}

func update_lod(camera_pos: Vector2):
    var distance = global_position.distance_to(camera_pos)
    
    if distance < lod_distances[LOD.FULL]:
        $AnimatedSprite2D.play()
        $GPUParticles2D.emitting = true
    elif distance < lod_distances[LOD.MEDIUM]:
        $AnimatedSprite2D.stop()
        $GPUParticles2D.emitting = false
    elif distance < lod_distances[LOD.LOW]:
        $AnimatedSprite2D.visible = false
    else:
        visible = false
```

## ✅ Sprite Checklist voor Production

### Technical Requirements
- [ ] Power of 2 atlas dimensions
- [ ] Nearest neighbor filtering
- [ ] No mipmaps for 2D
- [ ] Lossless compression
- [ ] Transparent background

### Visual Requirements
- [ ] Clear silhouette
- [ ] Readable at target size
- [ ] Neon glow compatible
- [ ] Distinct from other sprites
- [ ] Matches art style

### Performance Requirements
- [ ] Works in texture atlas
- [ ] Shares material with similar sprites
- [ ] LOD system compatible
- [ ] Under memory budget
- [ ] 60 FPS with 100+ instances

## 🚀 Quick Reference Card

```yaml
# TheCaves Sprite Standards
Project Settings:
  Base Resolution: 640x360
  Stretch Mode: viewport
  Scale Mode: integer

Sprite Sizes:
  Player: 48x48
  Enemy_Small: 32x32
  Enemy_Regular: 48x48
  Enemy_Elite: 64x64
  Boss: 128x128
  Projectile: 8x8 or 16x16

Performance Limits:
  Max Enemies: 100-150
  Draw Calls: < 100
  Memory: < 500MB
  FPS Target: 60
```

---

*Last Updated: December 2024*
*Based on: Godot 4.3 Documentation + Industry Standards*