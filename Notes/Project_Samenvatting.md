# Roguelite Game Project - Samenvatting

## Project Concept
- **Type**: Rogue-lite game 
- **Inspiratie**: Grottekeningen uit kunstmuseum
- **Visuele Stijl**: Neon/glow effecten met donkere achtergrond
- **Development**: Samenwerking met vriend
- **Doelgroep**: Fans van visueel opvallende indie games

## Copyright & Legale Aspecten
- ✅ **Grottekeningen**: Meestal publiek domein (duizenden jaren oud)
- ✅ **Eigen interpretatie**: Inspiratie nemen is toegestaan
- ⚠️ **Museumpresentaties**: Kunnen auteursrecht hebben op specifieke belichting
- 💡 **Aanpak**: Eigen stijl ontwikkelen geïnspireerd op primitieve kunst

## Game Engine Beslissing: Godot vs Unity

### Godot (Gekozen)
**Voordelen:**
- Uitstekende 2D renderer voor neon effecten
- WorldEnvironment systeem met ingebouwde glow
- Light2D nodes voor precisie effecten
- Gratis en open source
- Beginner-vriendelijker
- Sterke community support voor 2D effecten

**Technische Mogelijkheden:**
- Post-processing effects (glow, bloom)
- Visual shader editor (zoals Unity Shader Graph)
- Custom materials en shaders
- Particle systems voor extra sparkle

### Unity (Afgewezen)
**Redenen tegen:**
- Overkill voor 2D neon effecten
- URP/HDRP te complex voor beginners
- Licensing kosten
- Meer setup vereist voor 2D glow

## Concrete Voorbeelden Gevonden
1. **JDHunterZ/godot_neon**: Complete neon text animatie
2. **Godot-2D-Glow**: Runtime glow color changes
3. **Official Glow Demo**: 2D WorldEnvironment showcase
4. **Glowing and Blur Shaders**: Godot 4.0 tutorial met video

## Technische Implementatie

### Basis Setup
```gdscript
# WorldEnvironment instellingen
Background.Mode = Canvas
Glow.Enabled = true  
Glow.Blend_Mode = Screen
```

### Visuele Structuur
```
assets/
├── sprites/
│   ├── enemies/
│   │   ├── spiral_creature.png
│   │   └── tentacle_beast.png
├── shaders/
│   ├── neon_glow.gdshader
└── materials/
    └── enemy_materials/
```

### Neon Effect Workflow
1. Base sprite (zwart/donker)
2. Glow layer (bright colors) 
3. Post-processing voor bloom
4. Particle systems voor extra effecten

## Potentiële Problemen & Oplossingen

### Performance
- **Probleem**: Veel glow effects verlagen FPS
- **Oplossing**: LOD systeem, selective glow

### Visibility Issues  
- **Probleem**: Neon kan ogen vermoeien
- **Oplossing**: Contrast balancing, accessibility options

### Godot 4.x Specifiek
- **Probleem**: WorldEnvironment gloeit alles
- **Oplossing**: HDR 2D setting aanpassen in project settings

### Gameplay Clarity
- **Probleem**: Enemies moeten duidelijk zichtbaar blijven
- **Oplossing**: Consistent color coding, vorm herkenning

## Development Roadmap

### Fase 1: Proof of Concept
1. Godot installeren en setup
2. Glowing and Blur Shaders asset downloaden
3. Eerste test enemy maken met glow effect
4. Performance testen

### Fase 2: Art Pipeline
1. Grottekening stijl bepalen
2. Enemy designs maken (10-15 variaties)
3. Animation pipeline opzetten
4. Consistent glow materials maken

### Fase 3: Game Systems
1. Basic roguelike mechanics
2. Enemy AI met visual feedback
3. Room generation
4. Player progression

## Resources & Links
- **Godot Asset**: Glowing and Blur Shaders (MIT license)
- **GitHub**: JDHunterZ/godot_neon voor tekst animaties  
- **Tutorial**: Godot 4.0 glow effects YouTube serie
- **Community**: GodotShaders.com voor custom effects

## Next Actions
1. [ ] Godot 4.2+ downloaden
2. [ ] Glowing and Blur Shaders asset testen
3. [ ] Eerste enemy sprite maken
4. [ ] WorldEnvironment setup perfectioneren
5. [ ] Performance benchmark opstellen

## Tech Stack Confirmatie
- **Engine**: Godot 4.2+
- **Languages**: GDScript, GLSL (shaders)
- **Tools**: Godot Editor, externe art tools
- **Workflow**: Git voor version control, iterative development

---
*Notities gemaakt: Augustus 2025*
*Status: Engine gekozen, ready voor prototype fase*