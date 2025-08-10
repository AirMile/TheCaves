# 🚀 Dash Ability Feature

## Overzicht

Deze feature voegt een dash ability toe aan de player in TheCaves. De dash gebruikt officiele Godot patterns en integreert naadloos met het bestaande component systeem.

## ✨ Features

### Dash Mechanics
- **Input**: SHIFT, SPACE of gamepad X button
- **Standaard waarden**:
  - Dash snelheid: 400 pixels/seconde (2x base speed)
  - Dash duur: 0.2 seconden
  - Cooldown: 1.0 seconde

### Smart Direction Detection
1. Gebruikt huidige input direction (WASD)
2. Fallback naar huidige movement direction
3. Fallback naar Vector2.RIGHT als geen movement

### Component Integration
- **MovementComponent**: Dash logic en state management
- **Player**: Input handling en signal routing
- **AudioManager**: Dash sound effects
- **StatsComponent**: Upgradeable dash properties

## 🎮 Controls

| Input | Keyboard | Gamepad |
|-------|----------|---------|
| Movement | WASD | Left Stick |
| Dash | SHIFT / SPACE | X Button |

## 🔧 Technical Implementation

### Godot Best Practices Used
- `move_and_slide()` voor physics movement (Context7 documentatie)
- `_physics_process()` voor movement logic
- `Input.is_action_just_pressed()` voor single-activation dash
- Velocity-based movement via CharacterBody2D
- Signal-based component communication

### MovementComponent Changes
```gdscript
# Nieuwe dash properties
@export var dash_speed: float = 400.0
@export var dash_duration: float = 0.2  
@export var dash_cooldown: float = 1.0

# Dash state tracking
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO

# Nieuwe signals
signal dash_started
signal dash_ended
```

### Player Changes
```gdscript
# Nieuwe signal
signal dash_performed(direction: Vector2)

# Dash input handling in _physics_process()
func _handle_dash_input():
    if Input.is_action_just_pressed("dash"):
        # Smart direction detection & dash execution
```

## 🎯 Upgrade System Integration

De dash ability ondersteunt upgrades via het StatsComponent:

```gdscript
# Upgrade voorbeelden
{"type": "dash_speed", "value": 0.2}      # +20% dash speed
{"type": "dash_cooldown", "value": 0.25}  # -25% cooldown
```

## 🔊 Audio Integration

- `AudioManager.play_dash()` wordt automatisch aangeroepen
- Gebruikt bestaande audio pooling system
- Placeholder audio tot echte sound effects beschikbaar zijn

## 🛡️ Input Validation

- Input spam prevention (max 10 acties per frame)
- Input magnitude validation (prevent malicious input)
- Dash availability checks (cooldown + niet al aan het dashen)

## 📊 Debug Information

Extended debug info beschikbaar via:
```gdscript
# Player debug info
player.get_debug_info()
# Includes: can_dash, is_dashing, dash_cooldown_remaining

# MovementComponent debug info  
movement_component.get_debug_info()
# Includes: dash_speed, dash_duration, dash_cooldown
```

## 🧪 Testing

Voor het testen van de dash ability:

1. Start het spel (RefactoredArena scene)
2. Gebruik WASD voor movement
3. Druk SHIFT/SPACE voor dash
4. Observeer:
   - Dash in movement direction
   - Cooldown timer
   - Audio feedback
   - Console output voor debugging

## 🚀 Performance

- Dash gebruikt dezelfde physics pipeline als normale movement
- Geen extra allocaties tijdens runtime
- Timer-based state management voor precisie
- Volgt project performance guidelines (60 FPS target)

## 📁 Modified Files

- `scripts/components/MovementComponent.gd` - Dash logic
- `scripts/Player.gd` - Input handling  
- `project.godot` - Dash input mapping
- `README_DASH_FEATURE.md` - Deze documentatie

## 🔮 Future Enhancements

Mogelijke uitbreidingen:
- Dash through enemies (i-frames)
- Dash attack damage
- Multiple dash charges
- Dash trail effects
- Wall dash mechanics
- Dash reset on kill

---

*Feature ontwikkeld volgens TheCaves project standards en Godot best practices*