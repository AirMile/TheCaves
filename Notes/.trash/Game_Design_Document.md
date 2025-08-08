# Game Design Document v1.0

## 🎯 Core Game Concept
**Genre**: Action Rogue-lite met Shaman/Cave Art Aesthetic  
**Inspiration**: Vampire Survivors + Brotato + meer player agency  
**Visual Style**: Neon cave paintings op donkere achtergrond  
**Run Length**: 15 minuten (of korter)  
**Mood**: Spacey, trance-achtig, LSD-trip aesthetic  

## 🕹️ Controls & Input Systems

### Input Support
- ✅ **Keyboard + Mouse**: WASD movement, mouse aiming
- ✅ **Controller**: Twin-stick movement en targeting
- 🎮 **Implementation**: Godot Input Map voor beide

### Core Mechanics
**Movement**:
- Basic directional movement (8-direction)
- **Dash ability**: Quick movement burst met cooldown
- Movement speed base: ~200-300 pixels/sec

**Combat System**:
- **Passive attacks**: Auto-target nearby enemies
- **Manual abilities**: G-key (+ controller button) voor specials
- **Cooldown system**: Visual indicators voor ability timers
- **Weapon variety**: Melee, Magic, Projectile types

### Character Concepts
**Primary**: Shaman character met primitive aesthetic
**Potential**: Multiple character types met verschillende specializations
- Melee Shaman: Close combat, area damage
- Magic Shaman: Ranged spells, elemental effects  
- Hunter Shaman: Projectiles, precision targeting

## 🎨 Art & Visual Design

### Technical Specs
- **Resolution**: 1920x1080 target
- **Platform**: PC primary, consoles later
- **Performance**: Must run op low-end systems
- **Sprite Resolution**: TBD based op performance testing

### Visual Identity
- **Background**: Very dark (near black)
- **Characters**: Neon glow cave painting style
- **Lighting**: Limited vision mechanic (upgradeable)
- **Color Palette**: Dark base + bright neon accents
- **UI Style**: Clean, minimalistic, modern met neon touches

### Art Pipeline
- **Tools**: Digital art software (Krita/Photoshop/Procreate)
- **Hardware**: Drawing tablets (al beschikbaar)
- **Animation**: 4-8 frame cycles (afhankelijk van performance)
- **Asset Creation**: Beide partners doen art work

## 🎵 Audio Design

### Music Style
- **Genre**: Spacey, trance, ambient
- **Mood**: Psychedelic, otherworldly
- **Tool**: AI-generated music (Suno, Udio, etc.)
- **Implementation**: Dynamic layers based op intensity

### Sound Effects  
- **Creation**: AI-generated SFX
- **Style**: Atmospheric, primitive, maar modern
- **Integration**: Adaptive audio reageer op glow effects

## ⚙️ Technical Requirements

### Performance Targets
- **FPS**: Stable 60fps
- **Hardware**: Low-end PC compatible
- **Optimization**: Early testing van glow effects performance
- **Resolution Scaling**: Support voor verschillende screen sizes

### Development Tools
- **Engine**: Godot 4.2+
- **IDE**: VS Code met Godot extensions
- **Version Control**: Git met structured workflow
- **Art Tools**: Digital art suite (TBD)

## 🏗️ Development Structure

### Team Roles (Te besspreken vanavond)
**Jij**: Primary programming + art/design interest
**Partner**: Primary art + programming interest  
**Flexibele rollen**: Beide kunnen beide aspects doen

### Timeline
- **Intensieve Fase**: Augustus 2025 (1 maand full-time)  
- **School Periode**: 1 dag per week vanaf september
- **Milestone Reviews**: Weekly tijdens intensieve fase

### Git Workflow (Voorstel)
```
main branch: Stable releases
dev branch: Integration branch  
feature/character-movement: Individual features
feature/neon-shaders: Visual effects
feature/audio-system: Sound implementation
```

## 🎮 Gameplay Progression

### Core Loop
```
Spawn → Auto-attack enemies → Manual abilities → 
Collect XP/Items → Choose upgrades → New area → Repeat
```

### Upgrade Systems
- **Vision Range**: Expand what player can see
- **Ability Cooldowns**: Reduce manual ability timers
- **Auto-Attack**: Increase frequency/damage/range
- **Movement**: Faster speed, more dash charges
- **Magic Effects**: Neon trail effects, area damage

### Run Structure
- **Duration**: 10-15 minutes maximum
- **Progression**: Increasingly intense enemy waves  
- **Win Condition**: Survive timer of defeat final boss
- **Replayability**: Random upgrades, procedural elements

## 📋 Accessibility Features
- **Colorblind Support**: Alternative visual indicators
- **Font Scaling**: Adjustable text sizes  
- **Input Remapping**: Customizable controls
- **Audio Cues**: Sound indicators voor visual events

---

**Status**: Design phase - Ready voor prototype development  
**Next Phase**: Core mechanics prototype (movement + basic combat)  
**Created**: Augustus 2025


