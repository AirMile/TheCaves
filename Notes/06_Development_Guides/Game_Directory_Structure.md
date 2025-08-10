# TheCaves Game Directory Structure

## Root Directory Structure

```
TheCaves/
├── .claude/                    # Claude Code configuration files
├── .github/                   # GitHub Actions workflows
├── .godot/                    # Godot engine cache (auto-generated)
├── Notes/                     # Obsidian vault with documentation
├── godot-mcp/                # Godot MCP server integration
├── resources/                 # Game resource files (.tres)
├── scenes/                    # Godot scene files (.tscn)
├── screenshots/               # Development screenshots
├── scripts/                   # GDScript source code
├── project.godot             # Main Godot project file
├── CLAUDE.md                 # Claude development instructions
└── README.md                 # Project overview
```

## Scripts Directory (`/scripts/`)

### Autoload Singletons (`/scripts/autoload/`)
Core game systems that persist across scenes:
- `AudioManager.gd` - Sound effect and music management with object pooling
- `EnemyPool.gd` - Object pooling system for enemies (150 enemy capacity)
- `EventBus.gd` - Global event system for decoupled communication
- `GameManager.gd` - Game state management and progression
- `InputManager.gd` - Unified input handling (keyboard + controller)
- `ProjectileManager.gd` - Object pooling for bullets/projectiles (500 capacity)

### Component System (`/scripts/components/`)
Reusable components following composition pattern:
- `AIComponent.gd` - Enemy AI behavior with LOD (Level of Detail) optimization
- `HealthComponent.gd` - Health management with signals
- `HitboxComponent.gd` - Attack collision detection
- `HurtboxComponent.gd` - Damage receiving collision
- `MovementComponent.gd` - Movement logic with acceleration/friction
- `StatsComponent.gd` - Character statistics (damage, speed, etc.)
- `WeaponComponent.gd` - Weapon behavior and projectile spawning

### Interfaces (`/scripts/interfaces/`)
Abstract interfaces for consistent API:
- `IGameState.gd` - Game phase enumeration (Playing, Paused, GameOver, etc.)

### Resource Classes (`/scripts/resources/`)
Data containers for game configuration:
- `EnemyData.gd` - Enemy statistics and behavior parameters
- `GameConfiguration.gd` - Global game settings and balance
- `WaveConfiguration.gd` - Wave spawning patterns and difficulty

### Systems (`/scripts/systems/`)
High-level game logic coordinators:
- `GameManager.gd` - Main game flow and state transitions (renamed to ArenaGameManager)

### Individual Scripts
- `BasicEnemy.gd` - Simple enemy implementation
- `DebugPanel.gd` - Performance monitoring (F3 toggle)
- `Player.gd` - Player character controller
- `RefactoredArena.gd` - Main arena coordinator
- `SimpleTest.gd` - Basic testing scene
- `TestArena.gd` - Arena testing environment
- `TestDebugPanel.gd` - Debug panel testing
- `WorkingArena.gd` - Working arena implementation

## Scenes Directory (`/scenes/`)

### Main Scenes
- `Player.tscn` - Player character with components
- `RefactoredArena.tscn` - Main game arena with proper Camera2D setup
- `TestArena.tscn` - Testing environment
- `WorkingArena.tscn` - Working implementation reference
- `SimpleTest.tscn` - Simple test scene

## Resources Directory (`/resources/`)

### Game Configuration (`/resources/`)
- `DefaultGameConfig.tres` - Main game balance and settings
  - Player stats (health: 100, speed: 200, damage: 15)
  - Arena settings (800x600, max 150 enemies, 500 projectiles)
  - Performance targets (60 FPS, physics tick rate)
  - Audio volume levels
  - Debug settings

### Enemy Data (`/resources/enemies/`)
- `SwarmEnemy.tres` - Fast, weak enemies (25 HP, 120 speed, chase AI)
- `RangedEnemy.tres` - Medium enemies with ranged attacks (50 HP, 80 speed, ranged AI)

### Wave Configurations (`/resources/waves/`)
- `FirstWave.tres` - Initial wave configuration
  - Duration: 90 seconds
  - Max concurrent enemies: 6
  - Spawn configurations for swarm (weight 3.0) and ranged (weight 1.0)
  - Enemy budget: 20 total enemies

## Performance Architecture

### Object Pooling Strategy
```
EnemyPool (150 total capacity):
├── swarm: 80 instances      # Small, numerous enemies
├── ranged: 40 instances     # Medium count ranged attackers
├── tank: 20 instances       # Heavy, slow enemies
└── boss: 2 instances        # Rare boss encounters

ProjectileManager (500 capacity):
├── Player projectiles: 300
└── Enemy projectiles: 200

AudioManager (20 audio players):
└── Pooled AudioStreamPlayer2D instances
```

### Component-Based Entity System
Each game entity uses composition:
```
Enemy Entity:
├── HealthComponent      # HP management
├── MovementComponent    # Physics movement
├── AIComponent         # Behavior logic (with LOD)
├── HitboxComponent     # Attack collision
├── HurtboxComponent    # Damage reception
└── StatsComponent      # Damage, speed, etc.
```

### Level of Detail (LOD) System
Distance-based performance optimization:
- **HIGH (0-300px)**: Full AI, animation, abilities
- **MEDIUM (300-600px)**: Simple AI, animation only
- **LOW (600-900px)**: Basic movement only
- **MINIMAL (900px+)**: Position updates only

## Collision Layers
```
Layer 1: Walls           # Static environment
Layer 2: Player          # Player character
Layer 3: Enemies         # Enemy entities (no inter-enemy collision!)
Layer 4: Player Projectiles  # Player attacks
Layer 5: Enemy Projectiles   # Enemy attacks
Layer 6: Pickups         # Experience orbs, items
```

## Performance Targets
- **FPS**: 60 stable (55 minimum)
- **Enemies**: 100-150 simultaneous
- **Projectiles**: 200-300 active
- **Draw Calls**: <100 per frame
- **Physics Bodies**: <200 active
- **Memory**: <500MB RAM
- **Collision Pairs**: <5,000 (monitored via debug panel)

## Development Workflow Files

### Documentation (`/Notes/`)
Obsidian vault containing:
- `01_Design/` - Game design documents
- `02_Development/` - Implementation plans
- `06_Development_Guides/` - Technical guides and best practices

### Configuration Files
- `.claude/settings.local.json` - Claude Code settings
- `.github/workflows/` - CI/CD automation
- `project.godot` - Godot project configuration with autoloads

This structure supports the game's core requirement: maintaining 60 FPS with 100+ enemies through object pooling, component architecture, and LOD optimization systems.