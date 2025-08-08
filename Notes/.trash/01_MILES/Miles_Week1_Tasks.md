# 🎮 Miles - Week 1 Taken (7-13 Augustus)

## 🎯 Hoofddoelen Deze Week

### 1. Foundation Setup ✅
**Deadline: Donderdag 8 Augustus EOD**

#### A. Godot Project Structuur
```
roguelite-game/
├── scenes/
│   ├── player/
│   │   ├── Player.tscn
│   │   └── PlayerController.gd
│   ├── enemies/
│   ├── ui/
│   └── levels/
├── scripts/
│   ├── autoload/         # Singletons
│   │   ├── GameManager.gd
│   │   └── InputManager.gd
│   ├── components/       # Reusable components
│   └── systems/          # Game systems
├── assets/
│   ├── sprites/
│   │   ├── player/
│   │   └── enemies/
│   ├── audio/
│   └── shaders/
└── addons/              # Plugins
```

**Commands om uit te voeren:**
```bash
# In Godot project root
mkdir -p scenes/{player,enemies,ui,levels}
mkdir -p scripts/{autoload,components,systems}
mkdir -p assets/{sprites,audio,shaders}
mkdir -p assets/sprites/{player,enemies}
```

#### B. Git Repository Setup
```bash
# Initialize repository
git init
git remote add origin [jouw-github-url]

# Create .gitignore
cat > .gitignore << EOF
# Godot-specific ignores
.import/
.godot/
export.cfg
export_presets.cfg

# Mono-specific ignores
.mono/
data_*/

# System files
*.tmp
.DS_Store
Thumbs.db
EOF

# First commit
git add .
git commit -m "chore: initial project setup with Godot 4.x"
git push -u origin main
```

### 2. Claude Code Integration 🤖
**Deadline: Donderdag 8 Augustus**

#### Setup Instructions:
```bash
# In project root
claude-code init

# Create .claudeignore
cat > .claudeignore << EOF
.godot/
.import/
*.tmp
*.log
builds/
EOF

# Create .claude-instructions
cat > .claude-instructions << EOF
Project: Roguelite Game (Brotato-style)
Engine: Godot 4.x
Language: GDScript

Focus areas:
- Performance optimization for 100+ enemies
- Clean code architecture with composition
- Controller + keyboard input support
- Efficient sprite batching

Code style:
- Use static typing where possible
- Small focused functions (<20 lines)
- Comment complex logic
- Signals for decoupling
EOF
```

### 3. Player Movement System 🏃
**Deadline: Vrijdag 9 Augustus**

#### Core Features:
- [ ] WASD/Arrow keys movement
- [ ] Controller support (left stick)
- [ ] Smooth acceleration/deceleration
- [ ] 8-directional movement
- [ ] Collision with walls

#### PlayerController.gd Template:
```gdscript
extends CharacterBody2D
class_name Player

# Movement settings
@export var move_speed: float = 300.0
@export var acceleration: float = 2000.0
@export var friction: float = 1500.0

# Input
var input_vector: Vector2 = Vector2.ZERO

func _ready() -> void:
    # Setup gebeurt hier
    pass

func _process(_delta: float) -> void:
    handle_input()

func _physics_process(delta: float) -> void:
    apply_movement(delta)
    move_and_slide()

func handle_input() -> void:
    # Keyboard input
    input_vector.x = Input.get_axis("move_left", "move_right")
    input_vector.y = Input.get_axis("move_up", "move_down")
    input_vector = input_vector.normalized()

func apply_movement(delta: float) -> void:
    if input_vector != Vector2.ZERO:
        velocity = velocity.move_toward(input_vector * move_speed, acceleration * delta)
    else:
        velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
```

### 4. Input System Setup ⌨️🎮
**Deadline: Vrijdag 9 Augustus**

#### Project Settings → Input Map:
```
move_up: W, ↑, Controller D-Pad Up
move_down: S, ↓, Controller D-Pad Down
move_left: A, ←, Controller D-Pad Left
move_right: D, →, Controller D-Pad Right
dash: Space, Controller A/X
ability_1: Q, Controller LB
pause: ESC, Controller Start
```

### 5. Basic Test Level 🗺️
**Deadline: Zaterdag 10 Augustus**

- [ ] Simple rectangular arena (1920x1080)
- [ ] Wall collisions aan de randen
- [ ] Grid voor enemy spawn positions
- [ ] Debug overlay (FPS, entity count)

## 📝 Daily Checklist

### Donderdag 7 Augustus
- [ ] Godot installeren (4.3 stable)
- [ ] GitHub repository aanmaken
- [ ] Project structuur opzetten
- [ ] Claude Code configureren
- [ ] Discord channel setup met Jade

### Vrijdag 8 Augustus  
- [ ] Player scene maken
- [ ] Movement script implementeren
- [ ] Input mapping configureren
- [ ] Controller testen
- [ ] Commit: "feat: implement basic player movement"

### Weekend (10-11 Augustus)
- [ ] Test arena maken
- [ ] Collision layers setup
- [ ] Performance profiling beginnen
- [ ] Documentation schrijven
- [ ] Code review met Jade plannen

## 🚨 Belangrijke Aandachtspunten

### Performance vanaf Dag 1:
```gdscript
# GOED: Object pooling voorbereiden
var enemy_pool: Array[Enemy] = []

# SLECHT: Enemies constant instantiate/free
func spawn_enemy():
    var enemy = enemy_scene.instantiate()  # Vermijd dit 100x per frame
```

### Multiplayer-Ready Architecture:
```gdscript
# Scheidt input van movement
func _process(delta):
    var input = get_local_input()  # Later: of network input
    apply_input(input)
```

## 🔧 Tools & Resources

### VS Code Extensions:
```json
{
  "recommendations": [
    "geequlim.godot-tools",
    "alfish.godot-files",
    "GitHub.copilot",
    "eamodio.gitlens"
  ]
}
```

### Performance Monitoring:
```gdscript
# In GameManager.gd (autoload)
func _ready():
    if OS.is_debug_build():
        var perf_overlay = preload("res://debug/PerformanceOverlay.tscn").instantiate()
        get_tree().root.add_child(perf_overlay)
```

## ✅ Definition of Done

Een taak is "Done" wanneer:
1. Code werkt zonder errors
2. Getest met keyboard EN controller
3. Committed naar feature branch
4. PR gemaakt naar dev branch
5. Jade heeft kunnen testen

## 🆘 Hulp Nodig?

### Stuck? Gebruik Claude Code:
```bash
# Voor debugging
claude-code debug "player not moving"

# Voor code generation
claude-code generate "enemy spawn system"

# Voor optimization
claude-code optimize scenes/player/Player.gd
```

### Discord Check-ins:
- **Ochtend (10:00)**: "Plan voor vandaag: [taken]"
- **Avond (20:00)**: "Gedaan: [X], Blocker: [Y]"

---

## 📊 Week 1 Success Metrics

- [ ] Player kan bewegen met keyboard
- [ ] Player kan bewegen met controller
- [ ] Git workflow werkt voor beiden
- [ ] Claude Code geïntegreerd
- [ ] Basis project structuur staat
- [ ] Jade kan pullen en runnen

---

*💪 Focus: Foundation first, fancy features later!*