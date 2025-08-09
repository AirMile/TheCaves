# Technical Reference - Godot Neon Effects

## Quick Setup Checklist
- [ ] Install Godot 4.2+
- [ ] Create project with HDR 2D enabled
- [ ] Add WorldEnvironment node
- [ ] Configure glow settings

## Essential WorldEnvironment Settings
```
Background.Mode = Canvas
Glow.Enabled = true
Glow.Blend_Mode = Screen
Glow.Intensity = 1.0-2.0
Glow.Strength = 1.0-1.5
```

## Project Settings Fix
```
Project → Project Settings