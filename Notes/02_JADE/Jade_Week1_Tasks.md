# 🎨 Jade - Week 1 Taken (7-13 Augustus)

## 🎯 Hoofddoelen Deze Week

### 1. Art Style Exploration 🎨
**Deadline: Vrijdag 9 Augustus**

#### Test Sprites Maken:
Maak van **één enemy design** deze variaties:

##### A. Resolutie Tests
- [ ] 16x16 pixel versie
- [ ] 32x32 pixel versie  
- [ ] 64x64 pixel versie

##### B. Style Variaties (in 32x32)
- [ ] Pixel art (harde pixels, geen anti-aliasing)
- [ ] Smooth/painted style
- [ ] Neon outline style (voor glow effect)

##### C. Kleurenschema's
- [ ] Neon paars/blauw (hoofdthema)
- [ ] Complementair oranje/geel (voor contrast)
- [ ] Monochroom (voor special effects)

### 2. Software Setup 🖥️
**Deadline: Donderdag 8 Augustus**

#### Kies je primary tool:
- [ ] **Aseprite** (€20) - Best voor pixel art & animaties
- [ ] **Krita** (Gratis) - Goed voor painted style
- [ ] **Procreate** (iPad) - Als je tablet workflow wilt

#### Export Settings:
```
Format: PNG (transparante background)
Color Mode: RGBA
Bit Depth: 32-bit
Compression: None (voor development)
```

### 3. Enemy Concept Art 👾
**Deadline: Zaterdag 10 Augustus**

#### Basis Enemy Types (sketches):
1. **Swarm Type** (klein, veel)
   - Komt in groepen
   - Lage HP
   - 16x16 of 24x24 pixels

2. **Tank Type** (groot, langzaam)
   - Veel HP
   - Langzame movement
   - 48x48 of 64x64 pixels

3. **Ranged Type** (medium, schiet)
   - Projectiles
   - Keep distance
   - 32x32 pixels

### 4. Visual Effects Concepts ✨
**Deadline: Zondag 11 Augustus**

#### Glow/Neon Effect Research:
- [ ] Bekijk reference: Geometry Wars, Nex Machina
- [ ] Test in Godot: Sprite + Glow Layer
- [ ] Bepaal glow intensity (subtle vs intense)

#### Test Sheet Maken:
```
sprite_sheet_test.png
├── Frame 1: Base sprite
├── Frame 2: Inner glow only
├── Frame 3: Outer glow only
└── Frame 4: Combined effect
```

## 📐 Technische Specificaties

### Sprite Standards:
```yaml
Canvas Size: Power of 2 (16, 32, 64, 128)
Pivot Point: Center-bottom voor characters
Padding: 2px transparent border (voor glow)
Animation Frames: 4-8 voor walk cycles
Frame Rate: 10-12 FPS voor animations
```

### Naming Convention:
```
enemy_swarm_idle_32x32.png
enemy_swarm_walk_f1_32x32.png
enemy_swarm_walk_f2_32x32.png
player_dash_effect_64x64.png
ability_explosion_f1_128x128.png
```

### Color Palette (Neon Theme):
```css
/* Primary */
--neon-purple: #9D4EDD
--neon-blue: #5A189A  
--electric-blue: #3C096C

/* Secondary */
--neon-pink: #FF006E
--neon-orange: #FB5607
--bright-yellow: #FFBE0B

/* Effects */
--glow-white: #FFFFFF
--glow-core: #E0AAFF
```

## 🎮 Git Workflow voor Art Assets

### Asset Toevoegen:
```bash
# Op jouw feature branch
git checkout -b feature/enemy-sprites

# Voeg sprites toe
cp ~/Desktop/enemy_*.png assets/sprites/enemies/

# Commit met goede message
git add assets/sprites/enemies/
git commit -m "art: add enemy swarm sprite variations 32x32"

# Push naar GitHub
git push origin feature/enemy-sprites
```

### ⚠️ Let Op File Sizes:
- PNG sprites < 100KB per file = OK
- Grote files (> 1MB) = gebruik Git LFS:
```bash
git lfs track "*.psd"
git lfs track "*.kra"
git add .gitattributes
```

## 📱 Discord Sharing

### Voor Quick Feedback:
1. Exporteer als PNG
2. Post in #art-wip channel
3. Tag Miles voor feedback
4. Itereer based op feedback

### Feedback Template:
```markdown
**Nieuwe Sprite: [Enemy Swarm]**
- Resolution: 32x32
- Style: Neon outline
- Animation: 4 frames idle
- Notes: Niet zeker over kleur contrast

[Attach PNG]

Feedback gevraagd op:
- [ ] Leesbaarheid in-game
- [ ] Kleurenschema
- [ ] Animation timing
```

## 🔄 Daily Workflow

### Ochtend:
1. Check Discord voor feedback
2. Open Aseprite/Krita
3. Work on hoogste prioriteit sprite

### Middag:
4. Export test sprites
5. Test in Godot (Miles kan helpen)
6. Iterate based op in-game look

### Avond:
7. Final exports voor vandaag
8. Push naar Git
9. Update Discord met progress

## 📝 Week 1 Deliverables

### Must Have:
- [ ] 1 Enemy volledig (idle + walk animation)
- [ ] 3 Resolution tests (16/32/64)
- [ ] Style guide document
- [ ] Color palette finalized

### Nice to Have:
- [ ] Player sprite concept
- [ ] Projectile sprites
- [ ] UI mockup sketch
- [ ] Death animation test

## 🎯 Definition of Done voor Sprites

Een sprite is "Done" wanneer:
1. ✅ Transparent background
2. ✅ Correct resolution
3. ✅ Follows naming convention
4. ✅ Getest in Godot
5. ✅ Glow effect werkt
6. ✅ Miles approved voor implementation

## 💡 Pro Tips

### Pixel Perfect in Godot:
```gdscript
# In Project Settings
rendering/textures/canvas_textures/default_texture_filter = "Nearest"
```

### Animation Testing:
```gdscript
# Quick animation test script
@onready var sprite = $Sprite2D
var frames = [
    preload("res://assets/sprites/enemy_f1.png"),
    preload("res://assets/sprites/enemy_f2.png"),
    preload("res://assets/sprites/enemy_f3.png")
]
var current_frame = 0

func _ready():
    $Timer.timeout.connect(_next_frame)
    $Timer.wait_time = 0.1  # 10 FPS
    $Timer.start()

func _next_frame():
    sprite.texture = frames[current_frame]
    current_frame = (current_frame + 1) % frames.size()
```

## 🎨 Inspiration & References

### Games om te checken:
- **Geometry Wars 3** - Neon glow effects
- **Enter the Gungeon** - Sprite clarity
- **Nuclear Throne** - Animation efficiency  
- **Vampire Survivors** - Mass enemy readability

### Useful Links:
- [Lospec Palette List](https://lospec.com/palette-list)
- [Aseprite Tutorials](https://www.aseprite.org/docs/)
- [Pixel Art Tutorial](https://saint11.org/blog/pixel-art-tutorials/)

## ✅ End of Week Checklist

- [ ] Sprites gepusht naar repository
- [ ] Miles kan sprites importeren
- [ ] Glow effects work in-game
- [ ] Style guide gedocumenteerd
- [ ] Beslissing over resolutie (32x32?)
- [ ] Plan voor week 2 art taken

---

*🚀 Remember: Function > Form deze week! Mooie art komt later.*