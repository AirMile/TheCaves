# 🎨 Art Asset Pipeline

## 📐 Asset Specifications

### Sprite Dimensions
```yaml
Player:
  Size: 32x32 or 48x48
  Animations: idle(4), walk(8), dash(6), death(8)
  
Enemies:
  Swarm: 16x16 or 24x24
  Regular: 32x32
  Tank: 48x48 or 64x64
  Boss: 96x96 or 128x128
  
Projectiles:
  Bullets: 8x8
  Missiles: 16x8
  Explosions: 64x64 (sprite sheet)
  
UI:
  Icons: 32x32
  Buttons: 128x48
  Bars: 256x32
```

### Color Palette
```css
/* Neon Theme */
--primary-purple: #9D4EDD
--primary-blue: #5A189A
--accent-pink: #FF006E
--accent-cyan: #00F5FF
--glow-white: #FFFFFF
--glow-core: #E0AAFF

/* Enemies */
--enemy-red: #FF4444
--enemy-orange: #FF8800
--enemy-green: #44FF44

/* UI */
--ui-dark: #1A0033
--ui-light: #F0E6FF
--ui-gold: #FFD700
```

## 🔄 Workflow Steps

### 1. Concept → Sketch
```
Tool: Paper/Procreate
Size: Any
Time: 15-30 min
Output: rough_concept.png
```

### 2. Sketch → Pixel Art
```
Tool: Aseprite/Krita
Size: Target resolution
Time: 1-2 hours
Output: sprite_base.aseprite
```

### 3. Animation
```
Frames: 4-8 per animation
FPS: 10-12
Method: Onion skinning
Output: sprite_anim.aseprite
```

### 4. Export
```
Format: PNG (transparent)
Naming: entity_state_frame.png
Example: enemy_swarm_walk_01.png
```

### 5. Import to Godot
```
Location: res://assets/sprites/[category]/
Import Settings:
- Filter: Nearest (pixel perfect)
- Mipmaps: Disabled
- Compress: Lossless
```

## 📁 File Organization

```
assets/
├── sprites/
│   ├── player/
│   │   ├── player_idle_*.png
│   │   ├── player_walk_*.png
│   │   └── player_dash_*.png
│   ├── enemies/
│   │   ├── swarm/
│   │   ├── ranged/
│   │   └── tank/
│   ├── projectiles/
│   │   ├── bullets/
│   │   └── explosions/
│   ├── ui/
│   │   ├── buttons/
│   │   ├── icons/
│   │   └── panels/
│   └── effects/
│       ├── particles/
│       └── glow/
├── source_files/
│   ├── *.aseprite
│   ├── *.kra
│   └── *.psd
└── references/
    ├── mood_board/
    └── style_guide/
```

## 🎨 Style Guidelines

### Pixel Art Rules
1. **Consistent pixel size** - No mixed resolutions
2. **Limited colors** - Max 16 per sprite
3. **Clean outlines** - 1px black or colored
4. **Readable silhouettes** - Clear at distance
5. **Animation principles** - Squash, stretch, anticipation

### Neon Glow Effect
```
Layer Structure:
1. Base sprite (normal colors)
2. Inner glow (bright core)
3. Outer glow (colored fade)
4. Bloom (post-process in Godot)
```

### Visual Hierarchy
```
Size Importance:
Boss > Player > Tank > Regular > Swarm > Projectile

Glow Intensity:
Player (high) > Abilities > Enemies > Environment

Color Coding:
Player: Blue/Purple
Enemies: Red/Orange
Healing: Green
Damage: Red
Special: Gold
```

## 🔄 Animation Standards

### Frame Counts
```yaml
Idle: 4-6 frames
Walk/Run: 6-8 frames
Attack: 4-6 frames
Death: 6-10 frames
Special: 8-12 frames
```

### Timing
```yaml
Idle: 0.2s per frame (subtle)
Walk: 0.1s per frame (smooth)
Attack: 0.05s per frame (snappy)
Death: 0.15s per frame (dramatic)
```

### Export Settings
```bash
# Aseprite CLI export
aseprite -b sprite.aseprite \
  --save-as {slice}.png \
  --sheet sprite_sheet.png \
  --sheet-type rows \
  --sheet-pack
```

## 🖼️ Sprite Sheets

### Organization
```
sprite_sheet.png (256x256)
├── Row 1: Idle frames
├── Row 2: Walk frames
├── Row 3: Attack frames
└── Row 4: Death frames

Each frame: 32x32
Grid: 8x8 frames
```

### Godot Import
```gdscript
# AtlasTexture setup
var texture = preload("res://assets/sprites/sprite_sheet.png")
var frame = AtlasTexture.new()
frame.atlas = texture
frame.region = Rect2(0, 0, 32, 32)  # First frame
```

## 🎯 Quality Checklist

### Before Export
- [ ] Consistent pixel size
- [ ] No stray pixels
- [ ] Clean transparency
- [ ] Proper pivot point
- [ ] Animation loops smoothly

### After Import
- [ ] Pixel perfect rendering
- [ ] No filtering artifacts
- [ ] Correct collision shape
- [ ] Animations play correctly
- [ ] Performance acceptable

## 🔧 Tools & Settings

### Aseprite Settings
```json
{
  "pixel_perfect": true,
  "grid": {
    "width": 32,
    "height": 32,
    "visible": true
  },
  "onion_skin": {
    "enabled": true,
    "prev_frames": 2,
    "next_frames": 1
  }
}
```

### Krita Pixel Art
```
Brush: Pixel Art Presets
Interpolation: Nearest Neighbor
Canvas: Multiple of target size
Grid: Enabled, matching sprite size
```

### Godot Import Presets
```
Create preset: "Pixel Art"
- Filter: Nearest
- Mipmaps: Off
- Fix Alpha Border: On
- SRGB: On
```

## 📊 Performance Considerations

### Texture Sizes
- Mobile: Max 2048x2048
- PC: Max 4096x4096
- Prefer multiple small over one large

### Draw Calls
- Batch same sprites
- Use texture atlases
- Minimize unique materials

### Memory
```
32x32 sprite = ~4KB
64x64 sprite = ~16KB
128x128 sprite = ~64KB

Target: < 100MB for all sprites
```

## 🔄 Version Control

### What to Commit
```
✅ Final .png exports
✅ .aseprite source files
✅ Style guide updates
❌ Work-in-progress files
❌ High-res concepts
❌ PSD working files (use Git LFS)
```

### Commit Messages
```bash
git commit -m "art: add swarm enemy walk animation (8 frames)"
git commit -m "art: update player sprite colors for better contrast"
git commit -m "art: optimize sprite sheet layout for batching"
```

## 🎨 AI Asset Generation

### For Concepts
```
Prompt template:
"pixel art [subject], [size]x[size], 
[color palette], game sprite, 
top-down view, simple design"
```

### For Sound Effects
- Use Suno/Udio for music
- sfxr/bfxr for retro sounds
- Freesound.org for samples

### Guidelines
- Always edit AI output
- Maintain consistent style
- Check licensing
- Credit appropriately

---

*🎨 Remember: Gameplay > Graphics, but polish sells!*