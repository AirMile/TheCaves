# Sprite Resolution & Performance Guide

## 🔄 UPDATE: Resolution Decision
**Status**: We gaan eerst **32x32** testen (zie Development_Guides/Resolution_Standards.md)
**Backup**: Als te weinig detail → 64x64 zoals hieronder beschreven
**Test**: Jade maakt test sprites in beide resoluties

---

## 🎨 Resolution Recommendations

### **Voor Neon Glow Effects**

**Problemen met kleine sprites**:
- Glow effect kan sprite "overpower" bij 32x32
- Details gaan verloren in primitive art style
- Animaties moeten readable blijven

**Problemen met grote sprites**:  
- Meer fillrate = slechtere performance  
- Glow post-processing kost meer GPU
- Meer memory usage per sprite

### **Aanbevolen Approach**

**Start met 64x64 als baseline**:
- Genoeg detail voor cave painting style
- Glow effects blijven proportional  
- Goede performance op low-end hardware
- Makkelijk om later te downscalen naar 32x32

**Test Resolutions**:
1. **64x64**: Base recommendation  
2. **48x48**: Als performance issues
3. **96x96**: Voor belangrijke characters (player, bosses)
4. **32x32**: Emergency fallback

### **Performance Testing Strategy**

**Week 1 Test**:
```
Test Scene Setup:
- 1 Player (64x64) met glow
- 20 Enemies (64x64) met glow
- Dark background
- WorldEnvironment glow enabled
Target: 60fps op jouw zwakste test hardware
```

**Als FPS < 60**:
1. Reduce enemy count eerst
2. Dan sprite resolution verlagen  
3. Dan glow intensity verminderen
4. Last resort: selective glow (niet alle enemies)

## 🎬 Animation Frame Guidelines

### **Frame Counts per Animation Type**

**Idle Animation**: 2-4 frames
- Cave painting style = minimal movement
- Subtle breathing/glow pulsing
- Low priority voor frame count

**Walk Cycle**: 4 frames  
- Primitive art = simplified movement
- Focus op silhouette changes
- Smooth enough voor 60fps playback

**Attack Animations**: 3-6 frames
- Attack windup (1-2 frames)
- Impact frame (1 frame)  
- Recovery (1-3 frames)
- Snappy, responsive feeling

**Special Abilities**: 6-12 frames
- Meer dramatic voor manual abilities
- Glow intensity changes tijdens animatie
- Worth extra detail voor "juice"

### **Timing Guidelines**
```
Idle: 0.5-1.0 seconds per loop
Walk: 0.4-0.6 seconds per loop (afhankelijk movement speed)
Attack: 0.2-0.4 seconds total (must feel responsive)
Special: 0.5-1.0 seconds (can be slower, meer impact)
```

## 🔧 Art Asset Pipeline

### **File Organization**
```
art_assets/
├── concepts/
│   ├── character_sketches/
│   ├── enemy_designs/  
│   └── style_reference/
├── sprites/
│   ├── characters/
│   │   ├── shaman_idle_64x64.png
│   │   ├── shaman_walk_64x64.png
│   │   └── shaman_attack_64x64.png
│   └── enemies/
├── animations/
│   ├── character_anims/
│   └── enemy_anims/
└── ui/
    ├── hud_elements/
    └── menu_assets/
```

### **Naming Convention**
```
Format: [type]_[name]_[action]_[resolution].png

Examples:
char_shaman_idle_64x64.png
enemy_crawler_walk_64x64.png  
ui_health_bar_full.png
effect_glow_ring_96x96.png
```

### **Godot Import Settings**
```
Voor Sprites:
- Filter: OFF (pixel perfect)
- Mipmaps: OFF (2D game)
- Fix Alpha Border: ON (prevents glow bleeding)

Voor Animations:  
- Import als SpriteFrames resource
- FPS: Match je design (meist 12-24 fps)
```

## 🎯 Style Consistency Guide

### **Cave Painting Elements**
- **Thick outlines**: 2-3 pixel borders
- **Simple shapes**: Avoid complex details
- **Symbolic representation**: Stick figures, basic animal forms
- **Primitive proportions**: Niet realistic anatomy

### **Neon Integration**  
- **Glow color coding**: Red = dangerous, Blue = magic, etc.
- **Intensity levels**: Background glow vs active ability glow
- **Contrast maintenance**: Always readable against dark BG

### **Color Palette Suggestion**
```
Background: #0a0a0a (very dark gray)
Base sprites: #1a1a1a (dark gray - for contrast)
Neon colors:
- Electric Blue: #00ffff  
- Hot Pink: #ff0080
- Acid Green: #80ff00
- Solar Orange: #ff8000
- Deep Purple: #8000ff
```

## 📊 Performance Budget Template

**Target Hardware**: GTX 1050 / Integrated Graphics  
**FPS Target**: 60fps stable

**GPU Budget**:
- Sprite Rendering: 40% 
- Glow Post-processing: 35%
- Particle Effects: 15%
- UI Rendering: 10%

**Memory Budget**:  
- Sprite Textures: 100MB max
- Audio: 50MB max  
- Code/Scenes: 20MB max

**Als je deze limits bereikt**: Sprite resolution verlagen, glow quality verminderen, of enemy count limiteren.

---

**Next Actions**:
1. Test 64x64 sprites met glow in Godot
2. Performance benchmark met 20+ enemies
3. Adjust based op results
4. Document final specs in team style guide