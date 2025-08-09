# 🎨 Art Bible - TheCaves Visual Style Guide

## 🌈 Color Palette

### Primary Colors (Neon)
```css
--neon-magenta: #FF00FF;
--neon-cyan: #00FFFF;
--neon-yellow: #FFFF00;
--neon-green: #00FF00;
```

### Secondary Colors
```css
--deep-purple: #6B0BA8;
--electric-blue: #0080FF;
--hot-orange: #FF6600;
```

### Background & UI
```css
--bg-black: #0A0A0A;      /* Near black background */
--ui-dark: #1A1A1A;       /* UI panels */
--ui-light: #2A2A2A;      /* UI highlights */
--text-white: #FFFFFF;    /* Text */
```

---

## 🎨 Visual Style Direction

### Core Aesthetic
**"Neon Cave Paintings in the Dark"**
- Primitive, simplified shapes (cave art inspiration)
- Bright neon glow effects on dark backgrounds
- High contrast for gameplay clarity
- Psychedelic, trance-like atmosphere

### Style References
- **Cave Paintings**: Lascaux, Aboriginal art
- **Neon Games**: Geometry Wars, Tron, Nex Machina

---

## 👾 Character Design

### Player Character
- **Size**: 64x64 pixels
- **Shape**: Simplified humanoid, stick-figure inspired
- **Glow**: Bright cyan core with magenta outline
- **Animation**: 4-6 frame cycles

### Enemy Types

#### Swarm Enemy (Small)
- **Size**: 32x32 pixels
- **Color**: Yellow glow
- **Behavior**: Fast, weak, many

#### Standard Enemy
- **Size**: 48x48 pixels
- **Color**: Orange/Red glow
- **Behavior**: Balanced stats

#### Tank Enemy
- **Size**: 64x64 pixels
- **Color**: Purple glow
- **Behavior**: Slow, high HP

#### Boss
- **Size**: 128x128 pixels
- **Color**: Multi-color, pulsing
- **Behavior**: Complex patterns

---

## ✨ Effects & Particles

### Glow System
```
Layer 1: Base sprite (dark silhouette)
Layer 2: Inner glow (bright core color)
Layer 3: Outer glow (softer, larger)
Layer 4: Bloom post-processing (in Godot)
```

### Particle Effects
- **Hit**: Burst of colored sparks
- **Death**: Dissolve into particles
- **Power-up**: Rotating glow rings
- **Trail**: Fading neon lines

---

## 🎮 UI Design

### HUD Elements
- **Health**: Horizontal bar with glow
- **Abilities**: Circular icons with cooldown sweep
- **Score**: Digital font, neon glow
- **Minimap**: Simplified, high contrast

### Menu Style
- Dark background with subtle cave art patterns
- Neon highlighted buttons
- Smooth transitions with glow effects

---

## 📐 Technical Specifications

### Sprite Standards
- **Format**: PNG with transparency
- **Bit depth**: 32-bit RGBA
- **Pivot**: Center for rotating objects, bottom-center for characters
- **Padding**: 2px transparent border for glow bleed

### Animation Guidelines
- **Frame rate**: 12 FPS for most animations
- **Idle**: 4 frames
- **Walk/Run**: 6-8 frames
- **Attack**: 4-6 frames
- **Death**: 8-10 frames

### File Naming Convention
```
[type]_[name]_[state]_[frame].png

Examples:
player_shaman_idle_01.png
enemy_swarm_walk_03.png
effect_explosion_05.png
ui_healthbar_full.png
```

---

## 🔄 Asset Pipeline

1. **Concept** → Sketch/mockup
2. **Base Sprite** → Create in preferred tool
3. **Glow Layers** → Add inner/outer glow
4. **Export** → PNG with transparency
5. **Import to Godot** → Set import settings
6. **Test** → Check performance & visual quality

---

## 📋 Checklist for New Assets

- [ ] Matches color palette
- [ ] Has proper glow layers
- [ ] Readable at game zoom level
- [ ] Consistent with art style
- [ ] Optimized file size
- [ ] Properly named
- [ ] Tested in-game

---

## 🎯 Style Do's and Don'ts

### ✅ DO
- Keep shapes simple and iconic
- Use high contrast
- Make gameplay elements clear
- Test readability at different scales
- Maintain consistent glow intensity

### ❌ DON'T
- Add too much detail
- Use gradients in base sprites
- Mix art styles
- Forget gameplay clarity for aesthetics
- Make glow too subtle or too intense

---

*[[HOME|← Back to Home]] | [[01_Design/_Design_Index|← Back to Design]]*