# Roguelite Game Project - Summary

## Project Concept
- **Type**: Rogue-lite game 
- **Inspiration**: Cave paintings from art museum
- **Visual Style**: Neon/glow effects with dark background, lsd trip
- **Development**: Collaboration with friend
- **Target Audience**: Fans of visually striking indie games

## Game Engine Decision: Godot vs Unity

### Godot (Chosen)
**Advantages:**
- Excellent 2D renderer for neon effects
- WorldEnvironment system with built-in glow
- Light2D nodes for precision effects
- Free and open source
- More beginner-friendly
- Strong community support for 2D effects

**Technical Capabilities:**
- Post-processing effects (glow, bloom)
- Visual shader editor (like Unity Shader Graph)
- Custom materials and shaders
- Particle systems for extra sparkle

### Unity (Rejected)
**Reasons against:**
- Overkill for 2D neon effects
- URP/HDRP too complex for beginners
- Licensing costs
- More setup required for 2D glow

## Concrete Examples Found
1. **JDHunterZ/godot_neon**: Complete neon text animation
2. **Godot-2D-Glow**: Runtime glow color changes
3. **Official Glow Demo**: 2D WorldEnvironment showcase
4. **Glowing and Blur Shaders**: Godot 4.0 tutorial with video

## Technical Implementation

### Basic Setup
```gdscript
# WorldEnvironment settings
Background.Mode = Canvas
Glow.Enabled = true  
Glow.Blend_Mode = Screen
```

### Visual Structure
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
1. Base sprite (black/dark)
2. Glow layer (bright colors) 
3. Post-processing for bloom
4. Particle systems for extra effects

## Potential Problems & Solutions

### Performance
- **Problem**: Many glow effects lower FPS
- **Solution**: LOD system, selective glow

### Visibility Issues  
- **Problem**: Neon can tire eyes
- **Solution**: Contrast balancing, accessibility options

### Godot 4.x Specific
- **Problem**: WorldEnvironment glows everything
- **Solution**: Adjust HDR 2D setting in project settings

### Gameplay Clarity
- **Problem**: Enemies must remain clearly visible
- **Solution**: Consistent color coding, shape recognition

## Development Roadmap

### Phase 1: Proof of Concept
1. Install and setup Godot
2. Download Glowing and Blur Shaders asset
3. Create first test enemy with glow effect
4. Test performance

### Phase 2: Art Pipeline
1. Determine cave painting style
2. Create enemy designs (10-15 variations)
3. Set up animation pipeline
4. Create consistent glow materials

### Phase 3: Game Systems
1. Basic roguelike mechanics
2. Enemy AI with visual feedback
3. Room generation
4. Player progression

## Resources & Links
- **Godot Asset**: Glowing and Blur Shaders (MIT license)
- **GitHub**: JDHunterZ/godot_neon for text animations  
- **Tutorial**: Godot 4.0 glow effects YouTube series
- **Community**: GodotShaders.com for custom effects

## Next Actions
1. [ ] Download Godot 4.2+
2. [ ] Test Glowing and Blur Shaders asset
3. [ ] Create first enemy sprite
4. [ ] Perfect WorldEnvironment setup
5. [ ] Establish performance benchmark

## Tech Stack Confirmation
- **Engine**: Godot 4.2+
- **Languages**: GDScript, GLSL (shaders)
- **Tools**: Godot Editor, external art tools
- **Workflow**: Git for version control, iterative development

---
*Notes created: August 2025*
*Status: Engine chosen, ready for prototype phase*