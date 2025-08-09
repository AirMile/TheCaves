# GitHub Issue: Enemy & Boss Sprite Prototypes

**Copy deze text naar GitHub voor een nieuwe issue**

---

## 🎨 Enemy & Boss Sprite Prototypes - Phase 1

### Objective
Create sprite prototypes in verschillende resolutions en styles om de visual direction voor TheCaves te bepalen.

### Deliverables

#### Test Sprites (alle 3 styles)
- [ ] Player: 48x48 en 64x64
- [ ] Swarm Enemy: 32x32
- [ ] Regular Enemy: 48x48
- [ ] Elite Enemy: 64x64  
- [ ] Boss: 128x128
- [ ] Projectile: 8x8 en 16x16

#### 3 Art Styles om te Testen

**Style 1: Direct Moodboard**
- Exact zoals museum neon cave paintings
- Heldere neon kleuren op donkere achtergrond
- Primitive/simplified forms

**Style 2: Skeleton Concept**
- Jouw skeleton idee
- Glowing bones/joints
- Supernatural aesthetic

**Style 3: Cave Art Research**
- Research echte cave paintings (Lascaux, Aboriginal)
- Maak 3-5 variaties
- Adapt naar neon style

### Boss Concept: "The Sun Shaman"

Een boss gebaseerd op cave painting sun/spiral symbols:
- Centrale spiral/sun core
- Uitstralende energy tentacles  
- Meerdere glowing eyes
- Size: 128x128 (ongeveer 2.5x player grootte)

### Technical Requirements

#### Godot Import Settings
```
Filter: Nearest (pixel perfect)
Mipmaps: OFF
Compression: Lossless
```

#### File Naming
```
player_[style]_48x48.png
enemy_[style]_[type]_[size].png
boss_[style]_sunshaman_128x128.png
```

#### Texture Atlas (power of 2)
- Small sprites: 512x512 atlas
- Medium sprites: 1024x1024 atlas
- Boss sprites: 2048x2048 atlas

### Performance Testing

Test elke sprite size met:
- 100+ enemies on screen
- Check of 60 FPS blijft
- Monitor memory usage

### Recommended Priorities

1. **Player 48x48** - Most important, moet opvallen
2. **Swarm enemy 32x32** - Voor spawn testing
3. **Regular enemy 48x48** - Combat variety
4. **Boss 128x128** - Epic moment test
5. **Projectiles** - Performance testing

### Time Estimates

- 32x32 sprite: 3-4 uur (inclusief 8 frame animatie)
- 48x48 sprite: 4-5 uur
- 64x64 sprite: 5-7 uur  
- 128x128 boss: 10-15 uur

### Acceptance Criteria

- [ ] Sprites werken met integer scaling
- [ ] Glow effect zichtbaar zonder HDR
- [ ] Player altijd duidelijk zichtbaar
- [ ] Performance: 60 FPS met 100 enemies
- [ ] Alle 3 styles getest

### Resources

- [Moodboard op Miro/Discord]
- Cave art references: Lascaux, Aboriginal dot painting
- Godot Sprite Guide: `Notes/05_Development_Guides/Sprite_Performance_Guide.md`
- Size Standards: `Notes/05_Development_Guides/Sprite_Size_Standards.md`

### Notes

- Begin met 1 enemy type in alle 3 styles
- Test in Godot met WorldEnvironment glow
- Denk simpel voor kleine sprites (32x32)
- Player moet altijd grootste priority hebben voor visibility

---

**Labels**: `art`, `sprites`, `prototype`, `phase-1`, `jade`
**Assignee**: Jade
**Priority**: High
**Milestone**: Week 1 - Foundation