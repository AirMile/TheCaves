# 🎨 Enemy Sprite Exploration - Phase 1

## 📊 Sprite Resolution Testing

### ✅ BESLUIT: Gebaseerd op Godot Docs + Industry Standards

| Sprite Type | Chosen Size | Reason |
|------------|-------------|---------|
| **Player** | 48x48 | Visible, niet overwhelming |
| **Swarm Enemy** | 32x32 | 150+ enemies mogelijk |
| **Regular Enemy** | 48x48 | Goede detail/performance |
| **Elite Enemy** | 64x64 | Imposing maar manageable |
| **Boss** | 128x128 | Epic scale, 2.5x player |

### Resolution Test Results

#### 32x32 Pixels
**Best voor**: Swarm enemies, projectiles
**Pros:**
- Performance optimal voor 150-200 enemies
- Snelle productie (3-4 uur per sprite)
- Duidelijke silhouetten
- Texture atlas efficient (256 per 512x512)

**Cons:**
- Weinig detail mogelijk
- Glow kan sprite overweldigen

**Performance**: ✅ 200+ enemies @ 60 FPS

#### 48x48 Pixels  
**Best voor**: Player, regular enemies
**Pros:**
- Goede balans detail/performance
- Ruimte voor personality
- Player visibility guaranteed
- Industry standard (Brotato, Enter the Gungeon)

**Cons:**
- Meer productie tijd (4-5 uur)
- 100 enemy limit voor performance

**Performance**: ✅ 100 enemies @ 60 FPS

#### 64x64 Pixels
**Best voor**: Elite enemies, mini-bosses
**Pros:**
- Veel detail mogelijk
- Imposing presence
- Mooie glow effects
- Differentiation van regular enemies

**Cons:**
- Performance impact (max 30-50)
- Veel productie tijd (5-7 uur)

**Performance**: ⚠️ 50 enemies @ 60 FPS

#### 128x128 Pixels
**Best voor**: Bosses
**Pros:**
- Epic scale
- Full detail mogelijk
- Multiple animation states
- Screen presence

**Cons:**
- Hoge productie tijd (10-15 uur)
- Max 3-5 on screen
- Memory impact

**Performance**: ✅ 5 bosses @ 60 FPS

---

## 🎨 Style Explorations

### Style 1: Direct Moodboard (Neon Cave Paintings)
**Status**: In Development

**Key Elements:**
- Primitieve vormen zoals museum reference
- Felle neon kleuren (#00FFFF, #FF00FF, #FFFF00)
- Donkere achtergrond (#0A0A0A)
- Thick outlines (2-3 pixels)

**Test Sprites:**
1. Swarm Bat (32x32) - Simple flying creature
2. Cave Crawler (48x48) - Grounded enemy
3. Sun Shaman Boss (128x128) - Spiral/sun deity

**Feedback:**
- Glow works great op dark background
- Simple shapes read well at distance
- Neon colors zeer distinctive

### Style 2: Skeleton Concept
**Status**: Concept Phase

**Key Elements:**
- Bot structuur visible
- Glowing joints (cyan/magenta)
- Supernatural/undead feel
- Animated bones

**Test Sprites:**
1. Skeleton Warrior (48x48)
2. Bone Swarm (32x32)
3. Skeleton King Boss (128x128)

**Feedback:**
- Interesting silhouettes
- Glow op joints works well
- Animation potential high

### Style 3: Cave Art Research
**Status**: Research Phase

**Research Sources:**
- Lascaux Cave, France (animals, hunting scenes)
- Aboriginal dot painting (patterns, dreamtime)
- Prehistoric petroglyphs (symbols, spirals)
- Native American rock art (geometric patterns)

**Key Discoveries:**
- Simplified animal forms perfect voor enemies
- Spiral patterns voor magic/energy
- Stick figures voor humanoid enemies
- Dot patterns voor particle effects

**Adaptations for Neon:**
- Use bright colors waar cave art uses ochre
- Add glow to important elements
- Keep primitive line quality
- Emphasize silhouettes

---

## 🔬 Technical Tests in Godot

### Glow Shader Settings (Optimaal)
```gdscript
# WorldEnvironment settings
environment.background_mode = Environment.BG_CANVAS
environment.glow_enabled = true
environment.glow_intensity = 1.0
environment.glow_strength = 1.2
environment.glow_bloom = 0.1
environment.glow_blend_mode = Environment.GLOW_BLEND_MODE_SCREEN
environment.glow_hdr_threshold = 0.5  # Lower voor 2D
```

### Performance Test Results
| Resolution | Enemy Count | FPS | Memory | Draw Calls |
|------------|------------|-----|--------|------------|
| 32x32      | 150        | 60  | 125MB  | 45         |
| 32x32      | 200        | 58  | 140MB  | 52         |
| 48x48      | 100        | 60  | 180MB  | 55         |
| 48x48      | 125        | 56  | 210MB  | 68         |
| 64x64      | 50         | 60  | 250MB  | 65         |
| 128x128    | 5          | 60  | 300MB  | 72         |

**Conclusion**: Mix of 32x32 and 48x48 optimal

---

## 🎯 Decision Matrix

| Criteria | Style 1 (Moodboard) | Style 2 (Skeleton) | Style 3 (Cave Research) |
|----------|--------------------|--------------------|------------------------|
| **Readability** | 9/10 | 8/10 | 7/10 |
| **Production Speed** | 9/10 | 7/10 | 6/10 |
| **Unique Look** | 8/10 | 7/10 | 10/10 |
| **Animation Potential** | 7/10 | 9/10 | 6/10 |
| **Performance** | 9/10 | 8/10 | 9/10 |
| **Glow Compatibility** | 10/10 | 9/10 | 8/10 |
| **Total** | 52/60 | 48/60 | 46/60 |

**Winner**: Style 1 (Direct Moodboard) met elements van Style 3

---

## 📝 Meeting Notes & Feedback

### Week 1 Review
**Miles feedback:**
- 48x48 player voelt goed
- 32x32 enemies perfect voor swarms
- Boss moet echt imposing zijn (128x128 minimum)
- Glow effect is key voor atmosphere

**Jade thoughts:**
- 32x32 gaat snel, kan veel variatie maken
- 48x48 geeft genoeg ruimte voor detail
- 128x128 boss wordt een project op zich
- Style 1 meest feasible voor deadline

**Decisions:**
- Proceed met Style 1 als primary
- Mix in cave art elements waar mogelijk
- Player: 48x48 final
- Enemies: 32x32 (swarm), 48x48 (regular)
- Boss: 128x128 final

---

## ✅ Final Decision

**Chosen Resolutions:**
- Player: **48x48**
- Swarm Enemies: **32x32**
- Regular Enemies: **48x48**
- Elite Enemies: **64x64**
- Boss: **128x128**
- Projectiles: **8x8** en **16x16**

**Chosen Style:** 
**Style 1 (Direct Moodboard)** met cave art influences

**Reasoning:**
- Best performance/quality balance
- Fastest production pipeline
- Most distinctive visual style
- Glow effects werk perfect
- Matches museum inspiration

**Production Order:**
1. Player sprite (48x48) - Week 1
2. Basic swarm enemy (32x32) - Week 1
3. Regular enemy (48x48) - Week 1
4. Boss concept (128x128) - Week 2
5. Variations - Week 2-3

---

## 🚀 Next Steps

### Voor Jade:
- [ ] Finalize player sprite in Style 1
- [ ] Create 3 swarm enemy variations
- [ ] Design 2 regular enemy types
- [ ] Start boss concept sketches

### Voor Miles:
- [ ] Implement sprite loading system
- [ ] Setup texture atlases
- [ ] Create LOD system
- [ ] Test spawning performance

### Team:
- [ ] Review sprites in-game
- [ ] Test glow effects
- [ ] Finalize color palette
- [ ] Document sprite pipeline

---

*Last Updated: December 2024*
*Status: Style and Sizes CONFIRMED*