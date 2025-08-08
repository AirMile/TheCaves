# 🎮 TheCaves - Roguelite Game

A top-down roguelite game inspired by Brotato, Vampire Survivors, and Halls of Torment, featuring a unique neon cave painting aesthetic.

## 📊 Project Status
- **Phase**: Concept → Prototype
- **Engine**: Godot 4.3
- **Team**: Miles (Code Lead) & Jade (Art Lead)
- **Target**: 60 FPS with 100+ enemies

## 🚀 Quick Start

### Prerequisites
- Godot 4.3 or higher
- Git
- Obsidian (for documentation)

### Setup
```bash
# Clone repository
git clone https://github.com/AirMile/TheCaves.git
cd TheCaves

# Open in Godot
# 1. Launch Godot
# 2. Click "Import"
# 3. Navigate to project.godot
# 4. Click "Import & Edit"
```

### Documentation
Open the `Notes/` folder in Obsidian to access complete project documentation.

## 📁 Repository Structure

```
TheCaves/
├── Notes/                    # 📚 Project documentation (Obsidian vault)
│   ├── 00_START/            # Quick start guides
│   ├── 01_Design/           # Game design documents
│   ├── 02_Development/      # Sprint tracking
│   ├── 03_Team/             # Team dashboards
│   ├── 06_Development_Guides/ # Technical guides
│   ├── 07_Templates/        # Document templates
│   ├── [.obsidian/]         # ❌ Not in Git - personal settings
│   └── [.trash/]            # ❌ Not in Git - deleted files
├── scenes/                   # 🎬 Godot scene files
├── scripts/                  # 📜 GDScript files
├── assets/                   # 🎨 Game assets
│   ├── sprites/             # Sprites and textures
│   ├── audio/               # Sound effects and music
│   └── shaders/             # Visual shaders
├── resources/                # 📦 Godot resources
├── project.godot            # ⚙️ Project configuration
└── README.md                # 📖 This file
```

## 🎮 Game Features (Planned)

### Core Mechanics
- **Wave-based combat** - Survive increasingly difficult enemy waves
- **Auto-attack system** - Automatic targeting of nearby enemies
- **Manual abilities** - Player-triggered special attacks
- **Upgrade system** - Choose upgrades between waves
- **15-minute runs** - Quick, replayable sessions

### Technical Features
- **100+ enemies on screen** - Optimized with object pooling
- **Component architecture** - Flexible upgrade system
- **LOD system** - Performance scaling based on distance
- **Full controller support** - Keyboard & gamepad
- **Neon visual effects** - Unique cave painting aesthetic

## 🛠️ Tech Stack

- **Engine**: Godot 4.3
- **Language**: GDScript (static typing)
- **Architecture**: Component-based, Object pooling
- **Version Control**: Git
- **Documentation**: Obsidian (Markdown)
- **Performance Target**: 60 FPS @ 1080p

## 👥 Team

- **Miles** - Technical Lead
  - Systems programming
  - Performance optimization
  - Shader implementation
  
- **Jade** - Art Lead
  - Visual design
  - Animation
  - UI/UX

## 🔧 Development Setup

### Code Standards
- Static typing in GDScript
- Component-based architecture
- Object pooling for all spawnable objects
- Small functions (<20 lines)
- Clear naming conventions

### Git Workflow
```bash
# Feature branches
git checkout -b feature/enemy-spawning

# Commit format
git commit -m "feat(enemies): add wave spawning system"
git commit -m "fix(player): resolve dash collision bug"
git commit -m "docs: update performance guide"

# Push for review
git push origin feature/enemy-spawning
```

### Performance Requirements
- 60 FPS with 100+ enemies
- < 500MB RAM usage
- < 100 draw calls
- < 3 second load time

## 📚 Documentation

Comprehensive documentation available in `Notes/`:
- **Game Design Document** - Core vision and mechanics
- **Art Bible** - Visual style guide
- **Performance Guidelines** - Optimization strategies
- **Git Workflow** - Branching and commit conventions
- **Development Guides** - Technical implementation guides

## 🎯 Roadmap

### Current Sprint
- [ ] Neon shader system
- [ ] Player movement (WASD + Controller)
- [ ] Basic enemy AI
- [ ] Object pooling system

### Next Milestones
- [ ] Wave spawning system
- [ ] Upgrade system
- [ ] Multiple enemy types
- [ ] Sound integration
- [ ] UI implementation

## 🤝 Contributing

This is currently a private project. For team members:
1. Check your dashboard in `Notes/03_Team/[YourName]/`
2. Follow the Git workflow in `Notes/06_Development_Guides/Git_Workflow.md`
3. Update documentation as you work
4. Test performance with 100+ enemies

## 📄 License

This project is currently private. All rights reserved.

## 🔗 Links

- [Godot Engine](https://godotengine.org/)
- [Project Documentation](Notes/HOME.md)
- [Development Guides](Notes/06_Development_Guides/)
- [Current Sprint](Notes/02_Development/Current_Sprint.md)

---

*For detailed information, see the Notes directory or contact the team.*